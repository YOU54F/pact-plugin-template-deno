import { GrpcServer } from "https://deno.land/x/grpc_basic@0.4.6/server.ts";
import {
  InitPluginRequest,
  InitPluginResponse,
  PactPlugin,
  Catalogue,
  CompareContentsRequest,
  CompareContentsResponse,
  ConfigureInteractionRequest,
  ConfigureInteractionResponse,
  GenerateContentRequest,
  GenerateContentResponse,
  StartMockServerRequest,
  StartMockServerResponse,
  ShutdownMockServerRequest,
  ShutdownMockServerResponse,
  MockServerRequest,
  MockServerResults,
  VerificationPreparationRequest,
  VerificationPreparationResponse,
  VerifyInteractionRequest,
  VerifyInteractionResponse,
  Empty
} from "./plugin_inlined.d.ts";
import { getAvailablePort } from "https://deno.land/x/port/mod.ts";
import { protoFile } from "./pluginProtoUint8Array.ts";

const server = new GrpcServer();

const PactPluginService: PactPlugin = {
  InitPlugin(request: InitPluginRequest): Promise<InitPluginResponse> {
    console.log("InitPlugin");
    console.log(request);
    const response: InitPluginResponse = {
      catalogue: [
        {
          type: "CONTENT_MATCHER",
          key: "deno-plugin-matcher-example",
          values: { "content-types": "application/protobuf" }
        },
        {
          type: "CONTENT_GENERATOR",
          key: "deno-plugin-matcher-example",
          values: { "content-types": "application/protobuf" }
        },
        {
          type: "TRANSPORT",
          key: "grpc"
        }
      ]
    };
    console.log("InitPluginResponse");
    console.log(response);
    return Promise.resolve(response);
  },

  UpdateCatalogue(request: Catalogue): Promise<Empty> {
    console.log("UpdateCatalogue");
    console.log(request);
    return Promise.resolve(request);
  },

  CompareContents(
    request: CompareContentsRequest
  ): Promise<CompareContentsResponse> {
    console.log("CompareContents");
    console.log(request);
    return Promise.resolve({
      error: "string",
      typeMismatch: { expected: "expected", actual: "actual" },
      results: { mismatches: [] }
    });
  },

  ConfigureInteraction(
    request: ConfigureInteractionRequest
  ): Promise<ConfigureInteractionResponse> {
    console.log("ConfigureInteraction");
    console.log(request);
    return Promise.resolve({
      error: "error_string",
      interaction: []
      // pluginConfiguration: PluginConfiguration,
    });
  },

  GenerateContent(
    request: GenerateContentRequest
  ): Promise<GenerateContentResponse> {
    console.log("GenerateContent");
    console.log(request);
    return Promise.resolve({ contents: {} });
  },

  StartMockServer(
    request: StartMockServerRequest
  ): Promise<StartMockServerResponse> {
    console.log("StartMockServer");
    console.log(request);
    return Promise.resolve({
      // error?: string;
      // details?: MockServerDetails;
    });
  },

  ShutdownMockServer(
    request: ShutdownMockServerRequest
  ): Promise<ShutdownMockServerResponse> {
    console.log("ShutdownMockServer");
    console.log(request);
    return Promise.resolve({
      ok: true,
      results: [{ path: "path", error: "error", mismatches: [] }]
    });
  },

  GetMockServerResults(request: MockServerRequest): Promise<MockServerResults> {
    console.log("GetMockServerResults");
    console.log(request);
    return Promise.resolve({
      ok: true,
      results: [{ path: "path", error: "error", mismatches: [] }]
    });
  },

  PrepareInteractionForVerification(
    request: VerificationPreparationRequest
  ): Promise<VerificationPreparationResponse> {
    console.log("PrepareInteractionForVerification");
    console.log(request);
    return Promise.resolve({
      error: "error",
      interactionData: { body: {}, metadata: {} }
    });
  },

  VerifyInteraction(
    request: VerifyInteractionRequest
  ): Promise<VerifyInteractionResponse> {
    console.log("VerifyInteraction");
    console.log(request);
    return Promise.resolve({
      error: "error",
      result: {
        success: true,
        // responseData?: InteractionData;
        // mismatches?: VerificationResultItem[];
        output: ["woop", "woop", "from", "deno"]
      }
    });
  }
};

server.addService<PactPlugin>(new TextDecoder().decode(protoFile), {
  ...PactPluginService
});

const main = async () => {
  console.log(`Deno Pact Plugin`);
  const port: number = Deno.env.get("PORT")
    ? Number(Deno.env.get("PORT"))
    : (await getAvailablePort()) ?? 50052;
  console.log(JSON.stringify({ port, serverKey: crypto.randomUUID() }));
  for await (const conn of Deno.listen({ port })) {
    server.handle(conn);
  }
};

await main();
