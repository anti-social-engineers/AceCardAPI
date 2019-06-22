/*
 * Copyright 2019 Aaron Beetstra & Anti-Social Engineers
 *
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the MIT license.
 *
 */

package acecardapi.handlers;

import acecardapi.apierrors.InputFormatViolation;
import acecardapi.apierrors.InputLengthFormatViolation;
import acecardapi.apierrors.ParameterNotFoundViolation;
import acecardapi.auth.ReactiveAuth;
import acecardapi.models.Account;
import acecardapi.models.Deposit;
import acecardapi.models.Payment;
import acecardapi.models.Users;
import acecardapi.utils.RandomToken;
import acecardapi.utils.RedisUtils;
import io.reactiverse.pgclient.*;
import io.vertx.core.AsyncResult;
import io.vertx.core.Future;
import io.vertx.core.Handler;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.mail.MailClient;
import io.vertx.ext.mail.MailMessage;
import io.vertx.ext.web.RoutingContext;
import io.vertx.redis.client.RedisAPI;

import java.time.OffsetDateTime;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.UUID;

import static acecardapi.utils.EmailMessages.passwordResetMail;
import static acecardapi.utils.RequestUtilities.attributesCheckJsonObject;
import static acecardapi.utils.RequestUtilities.singlePathParameterCheck;
import static acecardapi.utils.StringUtilities.isString;

public class UserHandler extends AbstractCustomHandler {

  private String[] requiredAttributesPasswordForget = new String[]{"mail"};
  private String[] requiredAttributesPasswordResetProcess = new String[]{"token", "password"};

  private MailClient mailClient;
  private ReactiveAuth authProvider;

  public UserHandler(PgPool dbClient, JsonObject config, MailClient mailClient, ReactiveAuth authProvider) {
    super(dbClient, config);
    this.mailClient = mailClient;
    this.authProvider = authProvider;
  }

  public void getUserData(RoutingContext context) {
    System.out.println("Inside getUserData");

    dbClient.getConnection(getConn -> {
      if (getConn.succeeded()) {

        UUID userId = UUID.fromString(context.user().principal().getString("sub"));

        // First: Check if the user has a card or not
        PgConnection connection = getConn.result();

        connection.preparedQuery("SELECT is_activated, credits FROM cards WHERE user_id_id=$1", Tuple.of(userId), res -> {
          if (res.succeeded()) {

            if(res.result().rowCount() == 0) {
              System.out.println("This user has no card.");

              // User exists, but does not yet have an ace card

              connection.preparedQuery("SELECT email, role FROM users WHERE id=$1", Tuple.of(userId), res2 -> {

                if (res2.succeeded()) {
                  Row row2 = res2.result().iterator().next();
                  connection.close();
                  System.out.println("Connection has been closed, going to response: has no card");
                  getUserDataNoCard(context, row2.getString("email"), row2.getString("role"));
                } else {
                  raise500(context, res2.cause());
                  connection.close();
                }
              });

            } else {
              System.out.println("This user has a card.");

              // User has an ace card (or requested one)

              connection.preparedQuery("SELECT email, first_name, last_name, gender, date_of_birth, role, image_id FROM users WHERE id=$1", Tuple.of(userId), res2 -> {
                if (res2.succeeded()) {
                  Row row1 = res.result().iterator().next();
                  Row row2 = res2.result().iterator().next();

                  connection.close();
                  System.out.println("Connection has been closed, going to response: has card");
                  getUserDataWithCard(context, row1, row2);

                } else {
                  raise500(context, res2.cause());
                  connection.close();
                }
              });
            }

          } else {
            raise500(context, res.cause());
            connection.close();
          }
        });

      } else {
        raise500(context, getConn.cause());
      }
    });

  }

  private void getUserDataNoCard(RoutingContext context, String email, String role) {
    System.out.println("Generating response with no card....");
    Account acc = new Account(email, false, role);

    System.out.println("Sending with no card response....");
    raise200(context, acc.toJson());
  }

  private void getUserDataWithCard(RoutingContext context, Row cardRow, Row userRow) {
    // Generate Account response when user has a card


    System.out.println("Generating response with card....");
    Account acc = new Account(
      userRow.getString("first_name"),
      userRow.getString("last_name"),
      userRow.getString("email"),
      userRow.getLocalDate("date_of_birth"),
      userRow.getString("gender"),
      userRow.getString("role"),
      userRow.getUUID("image_id"),
      config.getString("http.image_dir", "static/images/"),
      true,
      cardRow.getBoolean("is_activated"),
      cardRow.getNumeric("credits").doubleValue()
    );

    System.out.println("Sending with card response....");
    raise200(context, acc.toJson());
  }

  public void userPayments(RoutingContext context) {


    if (!singlePathParameterCheck("sorting", context.request()))
      raise422(context, new ParameterNotFoundViolation("sorting"));
    else if (context.request().getParam("sorting").equals("desc") || context.request().getParam("sorting").equals("asc"))
    {
      if (singlePathParameterCheck("cursor", context.request())) {

        try {
          OffsetDateTime.parse(context.request().getParam("cursor"));
          processUserPayments(context, true);
        } catch (DateTimeParseException e) {
          raise422(context, new InputFormatViolation("cursor"));
        }

      } else {
        processUserPayments(context, false);
      }
    } else {
      raise422(context, new InputFormatViolation("sorting"));
    }
  }

  private void processUserPayments(RoutingContext context, boolean has_cursor) {

    if (has_cursor) {
      processUserPaymentsQuery(context, processUserPaymentsCursorQuery(context.request().getParam("sorting")), true);
    } else {
      processUserPaymentsQuery(context, processUserPaymentsQuery(context.request().getParam("sorting")), false);
    }

  }

  private void processUserPaymentsQuery(RoutingContext context, String query, boolean has_cursor) {

    dbClient.getConnection(getConnRes -> {
      if (getConnRes.succeeded()) {

        PgConnection connection = getConnRes.result();

        connection.preparedQuery("SELECT id FROM cards WHERE user_id_id = $1", Tuple.of(UUID.fromString(context.user().principal().getString("sub"))), cardRes -> {

          if (cardRes.succeeded()) {

            if (cardRes.result().rowCount() <= 0 || cardRes.result().rowCount() > 1) {
              connection.close();
            } else {

              UUID cardId = cardRes.result().iterator().next().getUUID("id");

              connection.preparedQuery(query, processUserPaymentsTuple(has_cursor, cardId, context.request().getParam("cursor")), paymentRes -> {

                 if (paymentRes.succeeded()) {

                   PgRowSet rows = paymentRes.result();

                   JsonArray jsonArray = new JsonArray();

                   for (Row row: rows) {
                     Payment payment = new Payment(row.getUUID("id"),
                       row.getNumeric("amount").doubleValue(),
                       row.getOffsetDateTime("paid_at"),
                       row.getString("club_name"));

                     jsonArray.add(payment.toJsonObject(true));
                   }

                   // Remove the last element from the list if row count > max return size

                   raise200(context, paymentsDepositsResponseHandler(rows, jsonArray, "payments"));
                   connection.close();


                 } else {
                   raise500(context, paymentRes.cause());
                   connection.close();
                 }

                });

            }

          } else {
            raise500(context, cardRes.cause());
            connection.close();
          }
        });

      } else {
        raise500(context, getConnRes.cause());
      }
    });

  }

  private String processUserPaymentsQuery(String order) {

    // We want to send back our LIMIT, but we also need to know the next item after limit
    int limit = config.getInteger("queries.max_return_size", 25) + 1;

    if (order.equals("desc")) {
      return "SELECT pa.id, pa.amount, pa.paid_at, cl.club_name FROM payments as pa INNER JOIN clubs as cl ON pa.club_id = cl.id WHERE pa.card_id_id = $1 ORDER BY pa.paid_at DESC LIMIT " + limit;
    } else {
      return "SELECT pa.id, pa.amount, pa.paid_at, cl.club_name FROM payments as pa INNER JOIN clubs as cl ON pa.club_id = cl.id WHERE pa.card_id_id = $1 ORDER BY pa.paid_at ASC LIMIT " + limit;
    }

  }

  private String processUserPaymentsCursorQuery(String order) {

    // We want to send back our LIMIT, but we also need to know the next item after limit
    int limit = config.getInteger("queries.max_return_size", 25) + 1;

    if (order.equals("desc")) {
      return "SELECT pa.id, pa.amount, pa.paid_at, cl.club_name FROM payments as pa INNER JOIN clubs as cl ON pa.club_id = cl.id WHERE pa.card_id_id = $1 AND pa.paid_at <= $2 ORDER BY pa.paid_at DESC LIMIT " + limit;
    } else {
      return "SELECT pa.id, pa.amount, pa.paid_at, cl.club_name FROM payments as pa INNER JOIN clubs as cl ON pa.club_id = cl.id WHERE pa.card_id_id = $1 AND pa.paid_at > $2 ORDER BY pa.paid_at ASC LIMIT " + limit;
    }

  }

  private Tuple processUserPaymentsTuple(boolean has_cursor, UUID cardId, String cursor) {

    if (has_cursor) {
      return Tuple.of(cardId, OffsetDateTime.parse(cursor));
    } else {
      return Tuple.of(cardId);
    }
  }

  public void userDeposits(RoutingContext context) {

    if (!singlePathParameterCheck("sorting", context.request()))
      raise422(context, new ParameterNotFoundViolation("sorting"));
    else if (context.request().getParam("sorting").equals("desc") || context.request().getParam("sorting").equals("asc"))
    {
      if (singlePathParameterCheck("cursor", context.request())) {

        try {
          OffsetDateTime.parse(context.request().getParam("cursor"));
          processUserDeposits(context, true);
        } catch (DateTimeParseException e) {
          raise422(context, new InputFormatViolation("cursor"));
        }

      } else {
        processUserDeposits(context, false);
      }
    } else {
      raise422(context, new InputFormatViolation("sorting"));
    }
  }

  private void processUserDeposits(RoutingContext context, boolean has_cursor) {

    if (has_cursor) {
      processUserDepositsQuery(context, processUserDepositsCursorQuery(context.request().getParam("sorting")), true);
    } else {
      processUserDepositsQuery(context, processUserDepositsQuery(context.request().getParam("sorting")), false);
    }

  }

  private void processUserDepositsQuery(RoutingContext context, String query, boolean has_cursor) {

    dbClient.getConnection(getConnRes -> {
      if (getConnRes.succeeded()) {

        PgConnection connection = getConnRes.result();

        connection.preparedQuery("SELECT id FROM cards WHERE user_id_id = $1", Tuple.of(UUID.fromString(context.user().principal().getString("sub"))), cardRes -> {

          if (cardRes.succeeded()) {

            if (cardRes.result().rowCount() <= 0 || cardRes.result().rowCount() > 1) {
              connection.close();
            } else {

              UUID cardId = cardRes.result().iterator().next().getUUID("id");

              connection.preparedQuery(query, processUserDepositsTuple(has_cursor, cardId, context.request().getParam("cursor")), depositsRes -> {

                if (depositsRes.succeeded()) {

                  PgRowSet rows = depositsRes.result();

                  JsonArray jsonArray = new JsonArray();

                  for (Row row: rows) {
                    Deposit deposit = new Deposit(row.getUUID("id"),
                      row.getNumeric("amount").doubleValue(),
                      row.getOffsetDateTime("deposited_at"));

                    jsonArray.add(deposit.toJsonObject());
                  }

                  raise200(context, paymentsDepositsResponseHandler(rows, jsonArray, "deposits"));
                  connection.close();

                } else {
                  raise500(context, depositsRes.cause());
                  connection.close();
                }

              });

            }

          } else {
            raise500(context, cardRes.cause());
            connection.close();
          }
        });

      } else {
        raise500(context, getConnRes.cause());
      }
    });

  }

  private String processUserDepositsQuery(String order) {

    // We want to send back our LIMIT, but we also need to know the next item after limit
    int limit = config.getInteger("queries.max_return_size", 25) + 1;

    if (order.equals("desc")) {
      return "SELECT id, amount, deposited_at FROM deposits  WHERE card_id_id = $1 AND status = $2 ORDER BY deposited_at DESC LIMIT " + limit;
    } else {
      return "SELECT id, amount, deposited_at FROM deposits  WHERE card_id_id = $1 AND status = $2 ORDER BY deposited_at ASC LIMIT " + limit;
    }

  }

  private String processUserDepositsCursorQuery(String order) {

    // We want to send back our LIMIT, but we also need to know the next item after limit
    int limit = config.getInteger("queries.max_return_size", 25) + 1;

    if (order.equals("desc")) {
      return "SELECT id, amount, deposited_at FROM deposits  WHERE card_id_id = $1 AND status = $2 AND deposited_at <= $3 ORDER BY deposited_at DESC LIMIT " + limit;
    } else {
      return "SELECT id, amount, deposited_at FROM deposits  WHERE card_id_id = $1 AND status = $2 AND deposited_at > $3 ORDER BY deposited_at DESC LIMIT " + limit;
    }
  }

  private Tuple processUserDepositsTuple(boolean has_cursor, UUID cardId, String cursor) {

    if (has_cursor) {
      return Tuple.of(cardId, "succeeded", OffsetDateTime.parse(cursor));
    } else {
      return Tuple.of(cardId, "succeeded");
    }
  }

  private JsonObject paymentsDepositsResponseHandler(PgRowSet rows, JsonArray jsonArray, String type) {

    String next_cursor = null;

    if (rows.rowCount() == config.getInteger("queries.max_return_size", 25) + 1) {
      next_cursor = jsonArray.getJsonObject(jsonArray.size() - 1).getString("time");
    }

    if (next_cursor != null) {
      jsonArray.remove(jsonArray.size() -1);

      return new JsonObject().put(type, jsonArray).put("next_cursor", next_cursor);
    } else {

      return new JsonObject().put(type, jsonArray).put("next_cursor", (String) null);
    }
  }

  /**
   * Function to generate graph data for spend/day for the last 30 days
   * @return void
   */
  public void paymentGraphData(RoutingContext context) {

    dbClient.getConnection(connectionRes -> {
      if (connectionRes.succeeded()) {

        PgConnection connection = connectionRes.result();

        connection.preparedQuery("SELECT id FROM cards WHERE user_id_id = $1", Tuple.of(UUID.fromString(context.user().principal().getString("sub"))), cardRes -> {

          if (cardRes.succeeded()) {

            PgRowSet cardResults = cardRes.result();

            if (cardResults.rowCount() == 0 || cardResults.rowCount() >= 2) {
              raise404(context);

              connection.close();

            } else {
              UUID cardId = cardResults.iterator().next().getUUID("id");

              connection.preparedQuery("SELECT CAST(paid_at AS DATE), SUM(amount) FROM payments WHERE paid_at > current_date - interval '30' day AND card_id_id = $1 GROUP BY CAST(paid_at AS DATE) ORDER BY CAST(paid_at AS DATE) DESC", Tuple.of(cardId), paymentRes -> {

                if (paymentRes.succeeded()) {
                  PgRowSet paymentResults = paymentRes.result();

                  JsonArray jsonArray = new JsonArray();
                  for (Row row: paymentResults) {
                    jsonArray.add(new JsonObject().put(row.getLocalDate("paid_at").toString(), row.getNumeric("sum")));
                  }

                  raise200(context, new JsonObject().put("type", "graph_data").put("data", jsonArray));

                  connection.close();

                } else {

                  raise500(context, paymentRes.cause());

                  connection.close();
                }

              });

            }

          } else {
            raise500(context, cardRes.cause());
            connection.close();
          }

        });

      } else {
        raise500(context, connectionRes.cause());
      }
    });
  }

  /**
   * Function to reset a forgotten password
   * @return void
   */
  public void passwordReset(RoutingContext context) {

    attributesCheckJsonObject(context.getBodyAsJson(), requiredAttributesPasswordForget, attributeRes -> {

      if (attributeRes.succeeded()) {

        if (isString(context.getBodyAsJson().getValue("mail"))) {

          doesUserExists(context.getBodyAsJson().getString("mail"), existRes -> {
            if (existRes.succeeded()) {

              if (existRes.result() == null) {
                raise404(context);
              } else {
                processUserExists(context, context.getBodyAsJson().getString("mail"), existRes.result());
              }

            } else {
              raise500(context, existRes.cause());
            }
          });
        } else {
          raise422(context, new InputFormatViolation("mail"));
        }

      } else {
        raise422(context, new ParameterNotFoundViolation(attributeRes.cause().getMessage()));
      }

    });

  }

  private void doesUserExists(String email, Handler<AsyncResult<UUID>> resultHandler) {

    dbClient.preparedQuery("SELECT id FROM users WHERE email = $1 and is_email_verified = $2", Tuple.of(email, true), res -> {

      if (res.succeeded()) {

        if (res.result().rowCount() <= 0 || res.result().rowCount() >= 2) {
          resultHandler.handle(Future.succeededFuture(null));
        } else {
          resultHandler.handle(Future.succeededFuture(res.result().iterator().next().getUUID("id")));
        }

      } else {
        resultHandler.handle(Future.failedFuture(res.cause()));
      }

    });

  }

  private void processUserExists(RoutingContext context, String email, UUID userId) {

    RandomToken token = new RandomToken(48);

    RedisAPI redisClient = RedisAPI.api(RedisUtils.backEndRedis);

    processUserExistRedis(redisClient, token, userId, res -> {
      if (res.succeeded()) {

        MailMessage message = passwordResetMail(email, res.result(), config.getString("password.reset_link", ""));

        mailClient.sendMail(message, result -> {
          if (result.succeeded()) {
            raise200(context);
          } else {
            raise500(context, result.cause());
          }
        });

      } else {
        raise500(context, res.cause());
      }
    });

  }

  private void processUserExistRedis(RedisAPI redisClient, RandomToken token, UUID userId, Handler<AsyncResult<String>> resultHandler) {

    String tokenValue = token.nextString();

    redisClient.exists(Arrays.asList(tokenValue), redisExist -> {
      if (redisExist.succeeded()) {
        if (redisExist.result().toInteger() == 1) {
          processUserExistRedis(redisClient, token, userId, resultHandler);
        }
        else {
          redisClient.set(Arrays.asList(tokenValue, userId.toString()), redisSetRes -> {
            if (redisSetRes.succeeded()) {
              redisClient.expire(tokenValue, config.getLong("password.forgot_exptime", 3600L).toString(), redisExpireRes -> {
                if (redisExpireRes.succeeded()) {
                  resultHandler.handle(Future.succeededFuture(tokenValue));
                } else {
                  resultHandler.handle(Future.failedFuture(redisExpireRes.cause()));
                }
              });
            } else {
              resultHandler.handle(Future.failedFuture(redisSetRes.cause()));
            }
          });
        }
      } else {
        resultHandler.handle(Future.failedFuture(redisExist.cause()));
      }
    });
  }

  public void processResetPassword(RoutingContext context) {

    attributesCheckJsonObject(context.getBodyAsJson(), requiredAttributesPasswordResetProcess, attRes -> {
      if (attRes.succeeded()) {

        if (!isString(context.getBodyAsJson().getValue("token"))) {
          raise422(context, new InputFormatViolation("token"));
        } else if (!isString(context.getBodyAsJson().getValue("password"))) {
          raise422(context, new InputFormatViolation("password"));
        } else if (context.getBodyAsJson().getString("password").length() < config.getInteger("password.length", 8)) {
          raise422(context, new InputLengthFormatViolation("password"));
        } else {
          RedisAPI redisAPI = RedisAPI.api(RedisUtils.backEndRedis);

          redisAPI.get(context.getBodyAsJson().getString("token"), redisRes -> {
            if (redisRes.succeeded()) {

              if (redisRes.result() == null) {
                raise404(context);
              } else {
                UUID userId = UUID.fromString(redisRes.result().toString());

                String newSalt = authProvider.generateSalt();
                String newPasswordHash = authProvider.computeHash(context.getBodyAsJson().getString("password"), newSalt);

                // Update the user with new hash + salt
                dbClient.preparedQuery("UPDATE users SET password = $1, password_salt = $2 WHERE id = $3", Tuple.of(newPasswordHash, newSalt, userId), updateUserRes -> {
                  if (updateUserRes.succeeded()) {

                    if (updateUserRes.result().rowCount() != 1) {
                      raise500(context, new Exception("[ResetPasswordProcess] Updated but no row was changed."));
                    } else {
                      raise200(context);

                      // If DEL fails, it should not matter: it will expire within 60 minutes
                      redisAPI.del(Arrays.asList(context.getBodyAsJson().getString("token")), delRedisRes -> {});
                    }

                  } else {
                    raise500(context, updateUserRes.cause());
                  }
                });
              }

            } else {
              raise500(context, redisRes.cause());
            }
          });
        }

      } else {
        raise422(context, new ParameterNotFoundViolation(attRes.cause().getMessage()));
      }
    });

  }

  public void getUsers(RoutingContext context) {

    dbClient.query("SELECT * FROM users", ar -> {
      if (ar.succeeded()) {
        PgRowSet result = ar.result();

        JsonArray jsonArray = new JsonArray();

        for (Row row: result) {

          Users users = new Users(row.getUUID("id"), row.getString("email"));

          jsonArray.add(users.toJsonObject());
        }

        raise200(context, jsonArray);

      } else {

        raise200(context, new JsonArray());

      }
    });
  }

}
