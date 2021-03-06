/*
 * Copyright (c) 2019. Aaron Beetstra & Anti-Social Engineers
 *
 *  All rights reserved. This program and the accompanying materials
 * are made available under the terms of the MIT license.
 *
 */

package acecardapi.models;


import io.vertx.core.json.JsonObject;
import org.owasp.encoder.Encode;

import java.text.DecimalFormat;
import java.time.LocalDate;
import java.util.UUID;

public class Account {

  private String first_name;
  private String last_name;
  private String email;
  private LocalDate dob;
  private String gender;
  private String role;
  private String image;
  private Boolean has_card;
  private Boolean active_card;
  private Double credits;

  public Account(String first_name, String last_name, String email, LocalDate dob, String gender, String role, UUID image_id, String image_path, Boolean has_card, Boolean active_card, Double credits) {
    this.first_name = first_name;
    this.last_name = last_name;
    this.email = email;
    this.dob = dob;
    this.gender = gender;
    this.role = role;

    if(image_id != null) {
      this.image = image_path + image_id.toString();
    } else {
      this.image = "";
    }
    this.has_card = has_card;
    this.active_card = active_card;
    this.credits = credits;
  }


  public Account(String email, Boolean has_card, String role) {
    this.email = email;
    this.has_card = has_card;
    this.role = role;
  }

  public JsonObject toJson() {
    if (has_card) {

      DecimalFormat decimalFormat = new DecimalFormat("0.00");
      String stringCredits = decimalFormat.format(credits);

      return new JsonObject()
        .put("first_name", Encode.forHtml(first_name))
        .put("surname", Encode.forHtml(last_name))
        .put("mail", Encode.forHtml(email))
        .put("dob", dob.toString())
        .put("gender", gender)
        .put("role", role)
        .put("image", image)
        .put("has_card", has_card)
        .put("active_card", active_card)
        .put("credits", stringCredits);
    } else {
      return new JsonObject()
        .put("mail", Encode.forHtml(email))
        .put("role", role)
        .put("has_card", has_card);
    }
  }

  public String getFirst_name() {
    return first_name;
  }

  public String getLast_name() {
    return last_name;
  }

  public String getEmail() {
    return email;
  }

  public LocalDate getDob() {
    return dob;
  }

  public String getGender() {
    return gender;
  }

  public String getRole() {
    return role;
  }

  public String getImage_path() {
    return image;
  }

  public Boolean getHas_card() {
    return has_card;
  }

  public void setFirst_name(String first_name) {
    this.first_name = first_name;
  }

  public void setLast_name(String last_name) {
    this.last_name = last_name;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public void setDob(LocalDate dob) {
    this.dob = dob;
  }

  public void setGender(String gender) {
    this.gender = gender;
  }

  public void setRole(String role) {
    this.role = role;
  }

  public void setImage_path(String image_path) {
    this.image = image_path;
  }

  public void setHas_card(Boolean has_card) {
    this.has_card = has_card;
  }
}

