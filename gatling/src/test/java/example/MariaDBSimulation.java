package example;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.util.concurrent.atomic.AtomicInteger;

public class MariaDBSimulation extends Simulation {

  private static final String BASE_URL = "http://localhost:30500";
  private static final AtomicInteger counter = new AtomicInteger(0);

  private static final HttpProtocolBuilder httpProtocol = http
      .baseUrl(BASE_URL)
      .acceptHeader("application/json")
      .contentTypeHeader("application/json");

  // CREATE
private static final ScenarioBuilder createScenario = scenario("MariaDB - Create")
    .exec(http("POST /mariadb/users")
        .post("/mariadb/users")
        .body(StringBody(session -> {
          int i = counter.incrementAndGet();
          return "{\"name\": \"User" + i + "\", \"email\": \"user" + i + "@test.com\"}";
        }))
        .check(status().is(201)));

// READ
private static final ScenarioBuilder readScenario = scenario("MariaDB - Read")
    .exec(http("GET /mariadb/users")
        .get("/mariadb/users")
        .check(status().is(200)));

// UPDATE
private static final ScenarioBuilder updateScenario = scenario("MariaDB - Update")
    .exec(http("POST /mariadb/users")
        .post("/mariadb/users")
        .body(StringBody("{\"name\": \"UpdatedUser\", \"email\": \"updated@test.com\"}"))
        .check(status().is(201))
        .check(jsonPath("$.id").saveAs("userId")))
    .exec(http("PUT /mariadb/users/:id")
        .put("/mariadb/users/#{userId}")
        .body(StringBody("{\"name\": \"ModifiedUser\"}"))
        .check(status().is(200)));

// DELETE
private static final ScenarioBuilder deleteScenario = scenario("MariaDB - Delete")
    .exec(http("POST /mariadb/users")
        .post("/mariadb/users")
        .body(StringBody("{\"name\": \"ToDelete\", \"email\": \"delete@test.com\"}"))
        .check(status().is(201))
        .check(jsonPath("$.id").saveAs("userId")))
    .exec(http("DELETE /mariadb/users/:id")
        .delete("/mariadb/users/#{userId}")
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