package example;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.util.concurrent.atomic.AtomicInteger;

public class ElasticSimulation extends Simulation {

  private static final String BASE_URL = "http://localhost:30500";
  private static final AtomicInteger counter = new AtomicInteger(0);

  private static final HttpProtocolBuilder httpProtocol = http
      .baseUrl(BASE_URL)
      .acceptHeader("application/json")
      .contentTypeHeader("application/json");

  private static final ScenarioBuilder createScenario = scenario("Elastic - Create")
      .exec(http("POST /elastic/users")
          .post("/elastic/users")
          .body(StringBody(session -> {
            int i = counter.incrementAndGet();
            return "{\"name\": \"User" + i + "\", \"email\": \"user" + i + "@test.com\"}";
          }))
          .check(status().is(201))
          .check(jsonPath("$.id").saveAs("docId")));

  private static final ScenarioBuilder readScenario = scenario("Elastic - Read")
      .exec(http("GET /elastic/users")
          .get("/elastic/users")
          .check(status().is(200)));

  private static final ScenarioBuilder updateScenario = scenario("Elastic - Update")
      .exec(http("POST /elastic/users")
          .post("/elastic/users")
          .body(StringBody("{\"name\": \"UpdatedUser\", \"email\": \"updated@test.com\"}"))
          .check(status().is(201))
          .check(jsonPath("$.id").saveAs("docId")))
      .exec(http("PUT /elastic/users/:id")
          .put("/elastic/users/#{docId}")
          .body(StringBody("{\"name\": \"ModifiedUser\"}"))
          .check(status().is(200)));

  private static final ScenarioBuilder deleteScenario = scenario("Elastic - Delete")
      .exec(http("POST /elastic/users")
          .post("/elastic/users")
          .body(StringBody("{\"name\": \"ToDelete\", \"email\": \"delete@test.com\"}"))
          .check(status().is(201))
          .check(jsonPath("$.id").saveAs("docId")))
      .exec(http("DELETE /elastic/users/:id")
          .delete("/elastic/users/#{docId}")
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
