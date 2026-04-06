package example;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import java.time.Duration;

public class RedisSimulation extends Simulation {

    private final HttpProtocolBuilder httpProtocol = http
            .baseUrl("http://localhost:30500")
            .acceptHeader("application/json")
            .contentTypeHeader("application/json");

    private final ScenarioBuilder redisScenario = scenario("Redis CRUD")

        // CREATE — POST /redis/session → {"session_id": "<uuid>"}
        .exec(
            http("POST /redis/session")
                .post("/redis/session")
                .body(StringBody("{\"user\": \"test\", \"role\": \"admin\"}")).asJson()
                .check(status().is(201))
                .check(jsonPath("$.session_id").saveAs("sessionId"))
        )
        .exitHereIfFailed()

        .pause(Duration.ofMillis(400))

        // READ
        .exec(
            http("GET /redis/session/:id")
                .get("/redis/session/#{sessionId}")
                .check(status().is(200))
        )

        .pause(Duration.ofMillis(300))

        // UPDATE
        .exec(
            http("PUT /redis/session/:id")
                .put("/redis/session/#{sessionId}")
                .body(StringBody("{\"user\": \"test\", \"role\": \"superadmin\"}")).asJson()
                .check(status().is(200))
        )

        .pause(Duration.ofMillis(300))

        // DELETE
        .exec(
            http("DELETE /redis/session/:id")
                .delete("/redis/session/#{sessionId}")
                .check(status().is(200))
        );

    {
        setUp(
            redisScenario.injectOpen(
                rampUsers(50).during(Duration.ofSeconds(300)),
                constantUsersPerSec(2).during(Duration.ofSeconds(1500))
            )
        )
        .maxDuration(Duration.ofMinutes(30))
        .protocols(httpProtocol);
    }
}
