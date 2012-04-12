$(document).ready(function() {
  /* Gets all the students and stores them */
  var all = {}
  $.get("/all", function(data) {
    all = data
    $("#client_input").typeahead({
      source: all,
      items: 8,
      matcher: function(item) {
        // Replaces spaces with any character plus a space 
        // facilitates finding of people with nicknames
        return new RegExp(this.query.replace(" ", ".* "), "i").test(item)
      }
    })
  })

  /* If this is the user's first visit, the #info_button will be rendered,
  which triggers a modal for updating preferences and setting the user 'active' */
  if (window.location.hash != "#screwers") {
    setTimeout(function() {
      $("#info_button").click()
    }, 200)
  }
  hash = window.location.hash;
  hashes = {
    "#screws": "#A",
    "#requests": "#E",
    "#screwers": "#B",
    "#profile": "#C"
  }
  if(hashes[hash])
    $("a[href='"+hashes[hash]+"']").click();
  else
    window.location.hash = "";

  /* Sets the nav bar style depending on url */
  loc = window.location.pathname;
  if(loc == "/") {
    $("li.home").addClass("active");
  }
  else if (loc == "/about")
    $("li.about").addClass("active");

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
  ]
  var slider_value = 6;
  $("#amount").html(slider_value);
  $("#amount_caption").html(captions[slider_value-1])

  $("#intensity").slider({
    animate: "normal",
    min: 1,
    max: 11,
    step: 1,
    value: slider_value,
    slide: function(event, ui) {
      $("#amount").html(ui.value);
      $("#amount_caption").html(captions[ui.value-1])
    }
  });

  /* ============== EVENT HANDLERS ================*/
  /* IMPORTANT NOTE: below, any reference to 'client' should be read as 'screwconnector' */
  var person = {}

  /* Makes alerts disappear on click anywhere */
  $("body").click(function() {
    $(".alert").slideUp("fast")
  })

  $(".help").click(function() {
    $("#help").slideToggle();
  })
  $("#help_close").click(function() {
    $("#help").slideUp("fast")
  })

  /* To logout of CAS */
  $("#logout").on("click", function() {
    $.get("/uncas");
  })

  $("a[href='#A']").click(function() {
    window.location.hash = "screws"
  })
  $("a[href='#E']").click(function() {
    window.location.hash = "requests"
  })
  $("a[href='#B']").click(function() {
    window.location.hash = "screwers"
  })
  $("a[href='#C']").click(function() {
    window.location.hash = "profile"
  })

  /* ======= SCREWS TAB ===== */
  /* Allows for add client on enter keypress */
  $("#client_input").keypress(function(e) {
    if(e.which == 13) {
      $("#add_client").click();
    }
    else {
      $("#client_box").removeClass("error")
    }
  })
  /* Removes modal target and re-adds it after error checking (see below) */
  $("#client_input").focus(function() {
    $("#add_client").attr("href", "")
  });
  /* Event handlers on 'screws' tab */
  $("#A").click(function(e) {
    t = e.target
    /* Deleting a client */
    if ($(t).hasClass("delete_client")) {
      $.post("/delete", {
        sc_id: $(t).attr("sc_id")
      }, function(data) {
        if(data.status == "success") {
          window.location.reload();
        }
        else if(data.status == "fail")
          $("#error").html(data.flash).parents(".alert").slideDown("fast")
      })
    }
    /* Adding a screwconnector from the screws tab (triggers modal) */
    else if ($(t).attr("id") == "add_client") {
      var val = $("#client_input").val()
      if(all.indexOf(val) != -1) {
        $.post("/whois", {name: val}, function(data) {
          if(data.status == "success") {
            person = data.person
            /* Sets values in modal */
            $("#screw_name").html(person.name+"!").show();
            $("#screw_id").val(person.id)
            $("#screw_select").html(person.select)
            $("#client_input").val("").attr("placeholder", "Your roommate/suitemate/loved one")
          }
          else if (data.status == "inactive") {
            $("#client_cancel").click();
            $("#info_button").click();
            console.log("inactive!")
          }
          else if (data.status == "fail") {
            $("#error").html(data.flash).parents(".alert").slideDown("fast")
          }
          
        })
        /* Sets the target of the 'Add!' button to trigger a modal (for error checking). Without this line, the modal won't trigger */
        $(t).attr("href", "#new_client")
      }
      else {
        $("#client_box").addClass("error")
        $("#client_input").focus().val("").attr("placeholder", "A valid name, please")
      }
    }
    /* Removes the target set above -- for error checking) */
    
    else if ($(t).attr("id") == "client_submit") {
      /* Creating a screwconnector from the modal */
      bod = $(t).parents(".modal")
      $.post("/new", {
        screw_id: $("#screw_id").val(),
        intensity: $("#intensity").slider("value"),
        event: $($(bod).find("select[name='event']")[0]).val()
      }, function(data) {
        if (data.status == "fail") {
          $("#error").html(data.flash).parents(".alert").slideDown("fast")
        }
        else {
          $("#success").html("Nice, you've got a new screw!").parents(".alert").slideDown("fast")
          if(!$(".client").length)
            $("#screws_container").html(data) 
          else
            $("#screws_container").append(data) 
          /* If the screwconnector that was created does not have its preferences (gender, major, gender preference, etc) set, this line triggers the modal that allows the user to set that */
          //if($(".client").last().find(".screw_match").length)
            $(".client").last().find(".screw_match").click();
        }

      })
      .error(ajax_error)
    }

    else if ($(t).hasClass("screw_match")) {
      $("#sc_sub").attr("sc_id", $(t).attr("sc_id"));
      $("#sc_sub").attr("p_id", $(t).attr("p_id"));
    }
    /* Updating the new screw's preferences/major */
    else if ($(t).attr("id") == "sc_sub") {
      bod = $(t).parents(".modal").find(".modal-body")[0];

      if(validate(t)) {
        $.post("/sc/info", {
          id: $(t).attr("p_id"),
          gender: $(bod).find("#gender").val(),
          preference: $(bod).find("#preference").val(),
          major: $(bod).find("#major").val(),
          nickname: $(bod).find("#nickname").val() 
        }, function(data) {
          if(data.status == "success") {
            window.location.reload();
          }
          else if (data.status == "fail") {
            $("#error").html(data.flash).parents(".alert").fadeIn("fast")
          }
        })
      }
    }
  });
  
  /* ====== REQUEST TAB ====== */

  /* accept request */
  $(".accept").click(function() {
    t = this
    $.post("/request/accept", {
      r_id: $(t).attr("r_id")
    }, function(data) {
      if (data.status == "success")
        window.location.reload();
      else if (data.status == "fail")
        $("#error").html(data.flash).parents(".alert").slideDown("fast")

    })
  })
  /* deny request */
  $(".deny").click(function() {
    t = this
    $.post("/request/deny", {
      r_id: $(t).attr("r_id")
    }, function(data) {
      if (data.status == "success") {
        $("#success").html(data.flash).parents(".alert").slideDown("fast");
        $(t).parents(".request").fadeOut(function(){
          $(t).parents(".request").remove();
          if (!$(".request").length) {
            $($("#E h6")[0]).after("<p>You have no more requests :(</p>")
          }
        })
      }
      else if (data.status == "fail")
        $("#error").html(data.flash).parents(".alert").slideDown("fast")

    })
  })
  /* cancel request */
  $(".cancel").click(function() {
    t = this
    $.post("/request/delete", {
      r_id: $(t).attr("r_id")
    }, function(data) {
      if (data.status == "success") {  
        $("#success").html(data.flash).parents(".alert").slideDown("fast");
        $(t).parents(".sent_request").fadeOut(function() {
          $(t).parents(".sent_request").remove();
          if (!$(".sent_request").length) {
            $($("#E h6")[0]).after("<p>No more pending requests :(</p>")
          }
        })
      }
      else if (data.status == "fail")
        $("#error").html(data.flash).parents(".alert").slideDown("fast")
    })
  })

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
    })
  })

  /* ======= PROFILE TAB ======= */
  /* Profile tab error checking */
  $(".info_in").focus(function() {
    $(this).parents(".control-group").removeClass("error")
  })
  /* Modal at the beginning */
  $("#info_submit").click(function(e) {
    modal_post(this, "/info", function(data) {
      if(data.status == "fail") {
        $("#error").html(data.flash).parents(".alert").slideDown("fast");
        setTimeout(function() {
          $("#info_submit").click();
        }, 500)
      }
      else {
        $("#user_info").html(data);
        $("#success").html("Welcome to Screw Me Yale! Start setting someone up by typing their name in the input box below!").parents(".alert").slideDown("fast");
      }

    })
  })
  /* Update post request from profile tab */
  $("#user_update").click(function() {
    bod = $(this).parents(".profile");
    $.post("/info", {
      gender: $(bod).find("#gender").val(),
      preference: $(bod).find("#preference").val(),
      major: $(bod).find("#major").val(),
      nickname: $(bod).find("#nickname").val()
    }, function(data) {
        $("#success").html("Attributes updated!").parents(".alert").slideDown("fast")
    })
  })

  /* ========== /match page =============== */

  /* Updates attributes on modal on /match/:id when matching with other screwconnectors */
  $(".match_link").click(function() {
    t = this;
    /* Set attributes on the submit button */
    $("#match_submit").attr("to_id", $(this).attr("sc_id"))

    $("#match_modal").find(".match_name").html($(t).attr("name"));

    bod = $("#match_modal").find(".modal-body");
    $(bod).find(".match_gen").html($(t).attr("gen"));
    $(bod).find(".match_pref").html($(t).attr("pref"));
    $(bod).find(".match_intensity").html($(t).attr("intensity"));
    $(bod).find(".match_event").html($(t).attr("event"));
    $(bod).find(".match_picture").attr("src", $(t).attr("picture"));
    $(bod).find(".match_major").html($(t).attr("major"));

  })
  /* The submit button from request confirmation modal */
  $("#match_submit").click(function() {
    $.post("/request", {
      to: $(this).attr("to_id"),
      from: $(this).attr("from_id")
    }, function(data) {
      if(data.status == "success") {
        $("#success").html(data.flash).parents(".alert").slideDown("fast")
      }
      else if (data.status == "fail") {
        $("#error").html(data.flash).parents(".alert").slideDown("fast")
      }
    })
  })
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

  })
})

function ajax_error() {
  $("#error").html("An error occurred -- please contact the webmaster or try again later :(").parents(".alert").slideDown("fast")
}

/* Easily post request from a modal. In the end, wasn't flexible enough for many cases, so is only called once... :-/ */ 
function modal_post(btn, url, cb) {
  if(validate(btn)) {
    bod = $(btn).parents(".modal").find(".modal-body")[0];
    $.post(url, {
      gender: $(bod).find("#gender").val(), 
      preference: $(bod).find("#preference").val(),
      major: $(bod).find("#major").val(),
      nickname: $(bod).find("#nickname").val()
    }, function(data) {
      if(typeof cb === "function") cb(data, btn);
    })
  }
  else {
    setTimeout(function() {
      $(btn).click()
    }, 500)
  }
}

/* Validates the standard _info partial */
function validate(obj) {

  bod = $(obj).parents(".modal").find(".modal-body")[0];
  nick = $(bod).find("#nickname")
  major = $(bod).find("#major")
  flag = true
  if($(major).val() == "") {
    flag = false
    $(major).parents(".control-group").addClass("error")
    $(major).attr("placeholder", "A major! (Undecided if you're unsure)")

  }
  /*
  else if($(nick).val() == "") {
    flag = false
    $(nick).parents(".control-group").addClass("error")
    $(nick).attr("placeholder", "A valid nickname, please!")
  }
  */
  return flag
}