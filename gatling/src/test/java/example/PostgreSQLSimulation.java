package example;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.util.concurrent.atomic.AtomicInteger;

public class PostgreSQLSimulation extends Simulation {

  private static final String BASE_URL = "http://localhost:30500";
  private static final AtomicInteger counter = new AtomicInteger(0);

  private static final HttpProtocolBuilder httpProtocol = http
      .baseUrl(BASE_URL)
      .acceptHeader("application/json")
      .contentTypeHeader("application/json");

  private static final ScenarioBuilder createScenario = scenario("Postgres - Create")
      .exec(http("POST /postgres/users")
          .post("/postgres/users")
          .body(StringBody(session -> {
            int i = counter.incrementAndGet();
            return "{\"name\": \"User" + i + "\"}";
          }))
          .check(status().is(201)));

  private static final ScenarioBuilder readScenario = scenario("Postgres - Read")
      .exec(http("GET /postgres/users")
          .get("/postgres/users")
          .check(status().is(200)));

  private static final ScenarioBuilder updateScenario = scenario("Postgres - Update")
      .exec(http("POST /postgres/users")
          .post("/postgres/users")
          .body(StringBody("{\"name\": \"UpdatedUser\"}"))
          .check(status().is(201))
          .check(jsonPath("$.id").saveAs("userId")))
      .exec(http("PUT /postgres/users/:id")
          .put("/postgres/users/#{userId}")
          .body(StringBody("{\"name\": \"ModifiedUser\"}"))
          .check(status().is(200)));

  private static final ScenarioBuilder deleteScenario = scenario("Postgres - Delete")
      .exec(http("POST /postgres/users")
          .post("/postgres/users")
          .body(StringBody("{\"name\": \"ToDelete\"}"))
          .check(status().is(201))
          .check(jsonPath("$.id").saveAs("userId")))
      .exec(http("DELETE /postgres/users/:id")
          .delete("/postgres/users/#{userId}")
          .check(status().is(200)));

  {
    setUp(
        createScenario.injectOpen(
            rampUsers(50).during(300),
            constantUsersPerSec(2).during(1500)
        ),
        readScenario.injectOpen(
            rampUsers(50).during(300),
            constantUsersPerSec(2).during(1500)
        ),
        updateScenario.injectOpen(
            rampUsers(30).during(300),
            constantUsersPerSec(1).during(1500)
        ),
        deleteScenario.injectOpen(
            rampUsers(30).during(300),
            constantUsersPerSec(1).during(1500)
        )
    ).protocols(httpProtocol);
  }
}