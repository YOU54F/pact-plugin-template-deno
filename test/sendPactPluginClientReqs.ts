import { getClient } from "https://deno.land/x/grpc_basic@0.4.6/client.ts";
import { protoFile } from "../src/pluginProtoUint8Array.ts";

const client = getClient({
  port: 50052,
  root: new TextDecoder().decode(protoFile),
  serviceName: "PactPlugin"
});

console.log(await client.InitPlugin({ name: "unary #1" }));
console.log(
  await client.UpdateCatalogue({
    catalogue: [
      {
        type: 0,
        key: "Hello",
        values: {
          Hello: "Hello"
        }
      }
    ]
  })
);

client.close();
