import { k8s, pulumi, docker } from "@codegram/pulumi-utils";
import * as k from "@pulumi/kubernetes";
import * as gcp from "@pulumi/gcp";
import * as random from "@pulumi/random";

/**
 * Get a reference to the stack that was used to create
 * the genesis Kubernetes cluster. In order to make it work you need to add
 * the `clusterStackRef` config value like this:
 *
 * $ pulumi config set clusterStackRef codegram/genesis-cluster/prod
 */
const stackReference = pulumi.getStackReference({
  name: pulumi.getValueFromConfig("clusterStackRef"),
});

const appsNamespace = stackReference.requireOutput("appsNamespaceName");

/**
 * Create a Kubernetes provider that will be used by all resources. This function
 * uses the previous `stackReference` outputs to create the provider for the
 * Genesis Kubernetes cluster.
 */
const kubernetesProvider = k8s.buildProvider({
  name: "regalocal",
  kubeconfig: stackReference.requireOutput("kubeconfig"),
  namespace: appsNamespace,
});

// DATABASE

export const dbPassword = new random.RandomPassword("regalocal-db-password", {
  length: 16,
  special: false,
});

export const db = new gcp.sql.DatabaseInstance("regalocal-db-instance", {
  databaseVersion: "POSTGRES_9_6",
  settings: {
    tier: "db-f1-micro",
    ipConfiguration: {
      authorizedNetworks: [{ value: "0.0.0.0/0" }],
    },
    databaseFlags: [{ name: "max_connections", value: "1000" }],
  },
});

const regalocalDatabase = new gcp.sql.Database("regalocal-db", {
  instance: db.name,
  name: "regalocal",
});

const dbUser = new gcp.sql.User("regalocal-db-instance-user", {
  instance: db.name,
  name: "regalocal",
  password: dbPassword.result,
});

/**
 * Create a new docker image. Use the `context` option to specify where
 * the `Dockerfile`is located.
 *
 * NOTE: to make this code work you need to add the following config value:
 *
 * $ pulumi config set gcpProjectId labs-260007
 *
 * The reason for that is we are pushing the docker images to Google cloud right now.
 */
const dockerImage = docker.buildImage({
  name: "regalocal",
  context: "../",
});

export const dbUrl = pulumi.interpolate`postgres://regalocal:${dbPassword.result}@${db.firstIpAddress}:5432/regalocal`;

const host: string = "www.regalocal.com";

const elixirCookie = new random.RandomPassword("regalocal-elixir-cookie", {
  length: 16,
  special: false,
});

const env: k.types.input.core.v1.EnvVar[] = [
  { name: "PORT", value: "8080" },
  { name: "HOST", value: host },
  { name: "DATABASE_URL", value: dbUrl },
  {
    name: "SECRET_KEY_BASE",
    value: pulumi.getSecretFromConfig("secretKeyBase", "regalocal"),
  },
  {
    name: "SENDGRID_PASSWORD",
    value: pulumi.getSecretFromConfig("sendgridPassword", "regalocal"),
  },
  {
    name: "SENDGRID_USERNAME",
    value: pulumi.getValueFromConfig("sendgridUsername", "regalocal"),
  },
  {
    name: "SENTRY_DSN",
    value: pulumi.getSecretFromConfig("sentryDsn", "regalocal"),
  },
  {
    name: "VEIL_REQUEST_SALT",
    value: pulumi.getSecretFromConfig("veilRequestSalt", "regalocal"),
  },
  {
    name: "VEIL_SESSION_SALT",
    value: pulumi.getSecretFromConfig("veilSessionSalt", "regalocal"),
  },
  {
    name: "GEOCODER_GOOGLE_API_KEY",
    value: pulumi.getSecretFromConfig("geocoderGoogleApiKey", "regalocal"),
  },
  {
    name: "CLOUDEX_SECRET",
    value: pulumi.getSecretFromConfig("cloudexSecret", "regalocal"),
  },
  {
    name: "CLOUDEX_CLOUD_NAME",
    value: pulumi.getValueFromConfig("cloudexCloudName", "regalocal"),
  },
  {
    name: "CLOUDEX_API_KEY",
    value: pulumi.getSecretFromConfig("cloudexApiKey", "regalocal"),
  },
  {
    name: "ADMIN_PASSWORD",
    value: pulumi.getSecretFromConfig("adminPassword", "regalocal"),
  },
  {
    name: "RELEASE_COOKIE",
    value: elixirCookie.result,
  },
  {
    name: "SERVICE_NAME",
    value: pulumi.interpolate`regalocal-service-private.${appsNamespace}.svc.cluster.local`,
  },
  {
    name: "HOSTNAME",
    valueFrom: {
      fieldRef: {
        fieldPath: "status.podIP",
      },
    },
  },
];

const labels = { app: "regalocal" };

const deployment = new k.apps.v1.Deployment(
  `regalocal-deployment`,
  {
    spec: {
      selector: { matchLabels: labels },
      replicas: 2,
      strategy: {
        type: "RollingUpdate",
        rollingUpdate: {
          maxSurge: 2,
          maxUnavailable: 1,
        },
      },
      template: {
        metadata: { labels },
        spec: {
          initContainers: [
            {
              name: "regalocal-migrate",
              image: dockerImage.imageName,
              imagePullPolicy: "IfNotPresent",
              command: ["bin/regalocal", "eval", "Regalocal.Release.migrate"],
              env,
            },
          ],
          containers: [
            {
              name: "regalocal",
              image: dockerImage.imageName,
              imagePullPolicy: "IfNotPresent",
              ports: [{ containerPort: 8080 }],
              command: ["bin/regalocal", "start"],
              env,
            },
          ],
        },
      },
    },
  },
  { provider: kubernetesProvider }
);

const privateService = new k.core.v1.Service(
  `regalocal-service-private`,
  {
    metadata: { name: "regalocal-service-private" },
    spec: {
      clusterIP: "None",
      ports: [{ name: "epmd", port: 4369 }],
      selector: labels,
    },
  },
  { provider: kubernetesProvider }
);

const service = new k.core.v1.Service(
  `regalocal-service`,
  {
    metadata: { labels },
    spec: {
      ports: [{ port: 80, targetPort: 8080 }],
      selector: labels,
    },
  },
  { provider: kubernetesProvider }
);

const ingress = new k.networking.v1beta1.Ingress(
  `regalocal-ingress`,
  {
    metadata: {
      labels,
      annotations: {
        "kubernetes.io/ingress.class": "nginx",
        "cert-manager.io/cluster-issuer": "letsencrypt-prod",
      },
    },
    spec: {
      tls: [{ hosts: [host], secretName: `regalocal-tls` }],
      rules: [
        {
          host,
          http: {
            paths: [
              {
                path: "/",
                backend: {
                  serviceName: service.metadata.name,
                  servicePort: 80,
                },
              },
            ],
          },
        },
      ],
    },
  },
  { provider: kubernetesProvider }
);
