package example;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import java.time.Duration;
import java.util.UUID;

public class CouchSimulation extends Simulation {

    private final HttpProtocolBuilder httpProtocol = http
            .baseUrl("http://localhost:30500")
            .acceptHeader("application/json")
            .contentTypeHeader("application/json");

    private final ScenarioBuilder couchScenario = scenario("CouchDB CRUD")

        // CREATE — POST /couch/users → {"id": "<uuid>"}
        .exec(
            http("POST /couch/users")
                .post("/couch/users")
                .body(StringBody(session -> {
                    String name = "user_" + UUID.randomUUID().toString().substring(0, 8);
                    return "{\"name\": \"" + name + "\", \"email\": \"" + name + "@test.com\"}";
                })).asJson()
                .check(status().is(201))
                .check(jsonPath("$.id").saveAs("docId"))
        )
        .exitHereIfFailed()

        .pause(Duration.ofMillis(400))

        // READ ALL
        .exec(
            http("GET /couch/users")
                .get("/couch/users")
                .check(status().is(200))
        )

        .pause(Duration.ofMillis(300))

        // UPDATE — Flask maneja _rev internamente
        .exec(
            http("PUT /couch/users/:id")
                .put("/couch/users/#{docId}")
                .body(StringBody("{\"name\": \"updated_user\", \"email\": \"updated@test.com\"}")).asJson()
                .check(status().is(200))
        )

        .pause(Duration.ofMillis(300))

        // DELETE
        .exec(
            http("DELETE /couch/users/:id")
                .delete("/couch/users/#{docId}")
                .check(status().is(200))
        );

    {
        setUp(
            couchScenario.injectOpen(
                rampUsers(50).during(Duration.ofSeconds(300)),
                constantUsersPerSec(2).during(Duration.ofSeconds(1500))
            )
        )
        .maxDuration(Duration.ofMinutes(30))
        .protocols(httpProtocol);
    }
}
