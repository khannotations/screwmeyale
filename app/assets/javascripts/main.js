$(document).ready(function() {
  /* Firefox quick-fix */
  if (navigator.userAgent.match(/firefox/i))
    alert("Sorry, this app doesn't work well on Firefox. Please try Chrome or Safari—NOT Internet Explorer");
  /* Gets all the students and stores them */
  var all = {};
  $.get("/all", function(data) {
    if(data) {
      all = data;
      $("#client_input").typeahead({
        source: all,
        items: 8,
        matcher: function(item) {
          // Replaces spaces with any character plus a space
          // facilitates finding of people with nicknames
          return new RegExp(this.query.replace(" ", ".* "), "i").test(item);
        }
      });
    }
    else
      ajax_error();
    
  }).error(ajax_error);

  loc = window.location.pathname;

  /* If this is the user's first visit, the #info_button will be rendered,
  which triggers a modal for updating preferences and setting the user 'active' */
  if (loc !== "/screwers") {
    setTimeout(function() {
      $("#info").modal({
        keyboard: false,
        backdrop: "static"
      })
      .modal("show");
    }, 200);
  }

  /* Controlling paths */

  var paths = {
    "/screws": "#A",
    "/requests": "#E",
    "/screwers": "#B",
    "/profile": "#C"
  };
  /* Routes to correct tab based on hash */
  /* Sets the nav bar style depending on url */

  if(paths[loc]) {
    $("a[href='"+paths[loc]+"']").click();
    $("li.home").addClass("active");
  }
  else if (loc === "/about") {
    $("li.about").addClass("active");
    $("li.help").hide();
  }
  else if (loc.match(/\/match\//)) {
    setTimeout(function() {
      window.location.reload();
    }, (60*60*1000)); // Reload page every hour to update screw options (inefficient, i know)
  }

  /* Makes the slider of the intensity picker */
  captions = [
    ": \"Wanna do homework after?\"",
    ": \"Holding hands is fun!\"",
    ": \"You can look but you can't touch\"",
    ": \"Let's boogie!\"",
    ": \"Call me, maybe?\"",
    ": \"Oooo I wanna dance with somebody\"",
    ": \"Party rock in the college\"",
    ": \"My hips don't lie\"",
    ": \"Tonight's gonna be a good night ;)\"",
    ": \"Straight up DTF\"",
    ": \"Blackout. By 10 p.m.\""
  ];
  var slider_value = 6;
  $("#amount").html(slider_value);
  $("#amount_caption").html(captions[slider_value-1]);

  $("#intensity").slider({
    animate: "normal",
    min: 1,
    max: 11,
    step: 1,
    value: slider_value,
    slide: function(event, ui) {
      $("#amount").html(ui.value);
      $("#amount_caption").html(captions[ui.value-1]);
    }
  });

  /* ============== EVENT HANDLERS ================*/
  /* IMPORTANT NOTE: below, any reference to 'client' should be read as 'screwconnector' */
  var person = {};

  /* Makes alerts disappear on click anywhere */
  $("body").click(function() {
    $(".alert").slideUp("fast");
  });

  $(".help").click(function() {
    $("#help").slideToggle();
  });
  $("#help_close").click(function() {
    $("#help").slideUp("fast");
  });

  /* To logout of CAS */
  $("#logout").on("click", function() {
    $.get("/uncas");
  });
  var back = false;

  /* History management */

  $("a.main-tab").click(function() {
    if(!back)
      window.history.pushState({view: $(this).attr("href")}, "Screw Me Yale",  $(this).html().toLowerCase().replace("/ /g", "")); // Strip, set as path
    back = false;
  });

  window.onpopstate = function(event) {
    l = (event.state && event.state.view) || "";
    back = true;
    $("a[href='"+l+"']").click();
  };

  $(".info_in").keypress(function(e) {
    if(e.which == 13) {
      $(this).parents(".modal").find(".btn").click();
    }
  });

  /* ======= SCREWS TAB ===== */
  /* Allows for add client on enter keypress */
  $("#client_input").keypress(function(e) {
    if(e.which == 13) {
      $("#add_client").click();
    }
    else {
      $("#client_box").removeClass("error");
    }
  });
  /* Removes modal target and re-adds it after error checking (see below) */
  $("#client_input").focus(function() {
    $("#add_client").attr("href", "");
  });
  /* Event handlers on 'screws' tab */
  $("#A").click(function(e) {
    t = e.target;
    /* Deleting a client */
    if ($(t).hasClass("delete_client")) {
      $.post("/delete", {
        sc_id: $(t).attr("sc_id")
      }, function(data) {
        if(data.status == "success") {
          window.location.reload();
        }
        else if(data.status == "fail")
          $("#error").html(data.flash).parents(".alert").slideDown("fast");
      }).error(ajax_error);
    }
    /* Adding a screwconnector from the screws tab (triggers modal) */
    else if ($(t).attr("id") == "add_client") {
      var val = $.trim($("#client_input").val());
      if(all.indexOf(val) != -1) {
        $.post("/whois", {name: val}, function(data) {
          if(data.status == "success") {
            person = data.person;
            /* Sets values in modal */
            $("#screw_name").html(person.name+"!").show();
            $("#screw_id").val(person.id);
            $("#screw_select").html(person.select);
            $("#client_input").val("").attr("placeholder", "Your roommate/suitemate/loved one");
          }
          else if (data.status == "inactive") {
            $("#client_cancel").click();
            $("#info_button").click();
          }
          else if (data.status == "fail") {
            $("#error").html(data.flash).parents(".alert").slideDown("fast");
          }
          
        }).error(ajax_error);
        /* Sets the target of the 'Add!' button to trigger a modal (for error checking). Without this line, the modal won't trigger */
        $(t).attr("href", "#new_client");
      }
      else {
        $("#client_box").addClass("error");
        $("#client_input").focus().val("").attr("placeholder", "A valid name, please");
      }
    }
    /* Removes the target set above -- for error checking) */
    
    else if ($(t).attr("id") == "client_submit") {
      /* Creating a screwconnector from the modal */
      bod = $(t).parents(".modal");
      $.post("/new", {
        screw_id: $("#screw_id").val(),
        intensity: $("#intensity").slider("value"),
        event: $($(bod).find("select[name='event']")[0]).val()
      }, function(data) {
        if (data.status == "fail") {
          $("#error").html(data.flash).parents(".alert").slideDown("fast");
        }
        else {
          $("#success").html("Nice, you've got a new screw!").parents(".alert").slideDown("fast");
          if(!$(".client").length)
            $("#screws_container").html(data);
          else
            $("#screws_container").append(data);
          /* If the screwconnector that was created does not have its preferences (gender, major, gender preference, etc) set, this line triggers the modal that allows the user to set that */
          //if($(".client").last().find(".screw_match").length)
          $(".client").last().find(".screw_match").click();
        }

      }).error(ajax_error);
    }

    else if ($(t).hasClass("screw_match")) {
      $("#sc_sub").attr("sc_id", $(t).attr("sc_id"));
      $("#sc_sub").attr("p_id", $(t).attr("p_id"));
    }
    /* Updating the new screw's preferences/major */
    else if ($(t).attr("id") == "sc_sub") {
      bod = $(t).parents(".modal").find(".modal-body")[0];

      if(validate(t)) {
        $(t).addClass("disabled");
        $.post("/sc/info", {
          id: $(t).attr("p_id"),
          gender: $(bod).find("#gender").val(),
          preference: $(bod).find("#preference").val(),
          major: $.trim($(bod).find("#major").val()),
          nickname: $.trim($(bod).find("#nickname").val())
        }, function(data) {
          if(data.status == "success") {
            window.location.reload();
          }
          else if (data.status == "fail") {
            $("#error").html(data.flash).parents(".alert").fadeIn("fast");
          }
        }).error(ajax_error);
      }
    }
  });
  
  /* ====== REQUEST TAB ====== */

  /* accept request */
  $(".accept").click(function() {
    t = this;
    $.post("/request/accept", {
      r_id: $(t).attr("r_id")
    }, function(data) {
      if (data.status == "success")
        window.location.reload();
      else if (data.status == "fail")
        $("#error").html(data.flash).parents(".alert").slideDown("fast");

    }).error(ajax_error);
  });
  /* deny request */
  $(".deny").click(function() {
    t = this;
    $.post("/request/deny", {
      r_id: $(t).attr("r_id")
    }, function(data) {
      if (data.status == "success") {
        $("#success").html(data.flash).parents(".alert").slideDown("fast");
        $(t).parents(".request").fadeOut(function(){
          $(t).parents(".request").remove();
          if (!$(".request").length) {
            $($("#E h6")[0]).after("<p>You have no more requests :(</p>");
          }
        });
      }
      else if (data.status == "fail")
        $("#error").html(data.flash).parents(".alert").slideDown("fast");

    }).error(ajax_error);
  });
  /* cancel request */
  $(".cancel").click(function() {
    t = this;
    $.post("/request/delete", {
      r_id: $(t).attr("r_id")
    }, function(data) {
      if (data.status == "success") {
        $("#success").html(data.flash).parents(".alert").slideDown("fast");
        $(t).parents(".sent_request").fadeOut(function() {
          $(t).parents(".sent_request").remove();
          if (!$(".sent_request").length) {
            $($("#E h6")[0]).after("<p>No more pending requests :(</p>");
          }
        });
      }
      else if (data.status == "fail")
        $("#error").html(data.flash).parents(".alert").slideDown("fast");
    }).error(ajax_error);
  });

  /* ======= SCREWER TAB ======= */
  /* Remove screwer */
  $(".remove_screwer").click(function() {
    t = this;
    $.post("/delete", {
      sc_id: $(t).attr("sc_id"),
      initiator: "screw"
    }, function(data) {
      if(data.status == "success") {
        $("#success").html(data.flash).parents(".alert").slideDown("fast");
        $(t).parents(".screwer").fadeOut(function(){
          $(t).parents(".screwer").remove();
        });
      }
      else if (data.status == "fail") {
        $("#error").html(data.flash).parents(".alert").slideDown("fast");
      }
    }).error(ajax_error);
  });

  /* ======= PROFILE TAB ======= */
  /* Profile tab error checking */
  $(".info_in").focus(function() {
    $(this).parents(".control-group").removeClass("error");
  });
  /* Modal at the beginning */
  $("#info_submit").click(function(e) {
    t = this;
    if(validate(t)) {
      bod = $(t).parents(".modal").find(".modal-body")[0];
      $.post("/info", {
        gender: $(bod).find("#gender").val(),
        preference: $(bod).find("#preference").val(),
        major: $(bod).find("#major").val(),
        nickname: $(bod).find("#nickname").val()
      }, function(data) {
        if(data.status == "fail") {
          $("#error").html(data.flash).parents(".alert").slideDown("fast");
          setTimeout(function() {
            $("#info_submit").click();
          }, 500);
        }
        else {
          $("#user_info").html(data);
          $("#success").html("Welcome to Screw Me Yale! Start setting someone up by typing their name in the input box below!").parents(".alert").slideDown("fast");
        }
      }).error(ajax_error);
    }
    else {
      setTimeout(function() {
        $("#info_button").click();
      }, 500);
    }
  }).error(ajax_error);
  /* Update post request from profile tab */
  $("#user_update").click(function() {
    t = this;
    $(t).addClass("disabled");
    bod = $(t).parents(".profile");
    $.post("/info", {
      gender: $(bod).find("#gender").val(),
      preference: $(bod).find("#preference").val(),
      major: $(bod).find("#major").val(),
      nickname: $(bod).find("#nickname").val()
    }, function(data) {
      if(data.status == "fail")
        $("#error").html(data.flash).parents(".alert").slideDown("fast");
      else {
        $("#user_info").fadeOut("fast", function() {
          $(this).html(data).fadeIn("fast");
          $("#success").html("Attributes updated!").parents(".alert").slideDown("fast");
          $(t).removeClass("disabled");
        });
      }
    }).error(ajax_error);
  });

  /* ========== /match page =============== */

  /* Updates attributes on modal on /match/:id when matching with other screwconnectors */
  $(".match_link").click(function() {
    t = this;
    /* Set attributes on the submit button */
    $("#match_submit").attr("to_id", $(this).attr("sc_id"));

    $("#match_modal").find(".match_name").html($(t).attr("name"));

    bod = $("#match_modal").find(".modal-body");
    $(bod).find(".match_gen").html($(t).attr("gen"));
    $(bod).find(".match_pref").html($(t).attr("pref"));
    $(bod).find(".match_intensity").html($(t).attr("intensity"));
    $(bod).find(".match_event").html($(t).attr("event"));
    $(bod).find(".match_picture").attr("src", $(t).attr("picture"));
    $(bod).find(".match_major").html($(t).attr("major"));

  });
  /* The submit button from request confirmation modal */
  $("#match_submit").click(function() {
    $.post("/request", {
      to: $(this).attr("to_id"),
      from: $(this).attr("from_id")
    }, function(data) {
      if(data.status == "success") {
        $("#success").html(data.flash).parents(".alert").slideDown("fast");
      }
      else if (data.status == "fail") {
        $("#error").html(data.flash).parents(".alert").slideDown("fast");
      }
    }).error(ajax_error);
  });
  /* The matches who don't have people currently screwing them */
  $(".unmatch_link").click(function() {
    t = this;
    $("#unmatch_modal").find(".match_name").html($(t).attr("name"));
    bod = $("#unmatch_modal").find(".modal-body");
    $(bod).find(".match_gen").html($(t).attr("gen"));
    $(bod).find(".match_pref").html($(t).attr("pref"));
    $(bod).find(".match_major").html($(t).attr("major"));
    $(bod).find(".match_picture").attr("src", $(t).attr("picture"));

    $(bod).find(".match_text").html($(t).attr("text"));
    $(bod).find(".match_names").html($(t).attr("names"));

  });
});

/* ========== HELPER FUNCTIONS ========= */

function ajax_error() {
  $("#error").html("An error occurred -- try refreshing the page. If the problem persists, please contact the webmaster or try again later :(").parents(".alert").slideDown("fast");
}

/* Validates the standard _info partial */
function validate(obj) {

  bod = $(obj).parents(".modal").find(".modal-body")[0];
  nick = $(bod).find("#nickname");
  major = $(bod).find("#major");
  flag = true;
  if($(major).val() === "") {
    flag = false;
    $(major).parents(".control-group").addClass("error");
    $(major).attr("placeholder", "A major! (Undecided if you're unsure)");

  }
  /*
  else if($(nick).val() == "") {
    flag = false
    $(nick).parents(".control-group").addClass("error")
    $(nick).attr("placeholder", "A valid nickname, please!")
  }
  */
  return flag;
}