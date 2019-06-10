/*
 * Copyright 2019 Aaron Beetstra & Anti-Social Engineers
 *
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the MIT license.
 *
 */

package acecardapi.models;

import io.reactiverse.pgclient.Tuple;
import io.vertx.core.json.JsonObject;

import java.time.OffsetDateTime;
import java.util.UUID;

public class Payment {

  private UUID id;
  private Double amount;
  private OffsetDateTime paid_at;
  private UUID cardId;
  private UUID clubId;

  public Payment(Double amount, UUID cardId, UUID clubId) {
    this.id = UUID.randomUUID();
    this.amount = amount;
    this.paid_at = OffsetDateTime.now();
    this.cardId = cardId;
    this.clubId = clubId;
  }

  public Tuple toTuple() {
    return Tuple.of(id, amount, paid_at, cardId, clubId);
  }

  public JsonObject toJsonObject() {
    return new JsonObject()
      .put("id", id.toString())
      .put("amount", amount.toString())
      .put("time", paid_at.toString());
  }

}
