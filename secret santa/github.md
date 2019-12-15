Gift exchange organizer completely in R, without giving your emails to
any external service.

For that we will use the packages blastula, dplyr and purrr.

    library(blastula)
    library(tidyverse)

Concept is to send emails to each of the participants with who needs to
give a gift to. For that the organizer needs a valid email address that
will be the one used to send all the emails. It is recommended this to
be a secondary or not very used email. In order to avoid the temptation
of looking the sent emails. Or then just ask somebody else to do this in
the groups behalf.

    sender_email <- "my_email@yahoo.com"

First step is to create a data frame with the names and emails of all
the participants

    participants <- tribble(~name,~email,
    "Rachel", "rachel_friends@gmail.com",
    "Monica", "monica_friends@gmail.com",
    "Phoebe",  "phoebe_friends@gmail.com",
    "Joey", "joey_friends@gmail.com",
    "Chandler", "chandler_friends@gmail.com",
    "Ross", "ross_friends@gmail.com",)
    participants

In order to be able to send an email from R we first need to create a
file with the credentials. Note that with yahoo, only way is to do this
is to create a one-time password. For other email services (gmail,
outlook etc.) look at the documentation of bastula:

<a href="https://rich-iannone.github.io/blastula/reference/create_smtp_creds_file.html" class="uri">https://rich-iannone.github.io/blastula/reference/create_smtp_creds_file.html</a>

    create_smtp_creds_file(file="yahoo_credential", user = sender_email, 
      host = "smtp.mail.yahoo.com", port = 587, use_ssl = TRUE)

Function to create one email. Body and footer of email can be
customized.

    send_secret_santa_email <- function(gift_giver_email,gift_recipient,mail_cred_file){
     email <-compose_email(
        body = glue::glue("Ho Ho Ho,

    This is secret Santa. My job is to delegate giving presents.

    You need to give a present to {gift_recipient}"),
    footer = "All done in R")
     
     email %>%
      smtp_send(
        to = gift_giver_email,
        from = sender_email,
        subject = "Secret Santa",
        credentials = creds_file(mail_cred_file)
      )
    }

    send_secret_santa_email("monica_friends@gmail.com","Joey","yahoo_credential")

In order to shuffle the particpants, assign a person to each and send
and email to each with the info, use the following function. Inspiration
for the shuffling taken from:
<a href="https://selbydavid.com/2016/12/07/santa/" class="uri">https://selbydavid.com/2016/12/07/santa/</a>

    assign_batch_emails <- function(names_email){
      shuffle_names <- sample(names_email$name)
     gifts_assigned <-  tibble(sender = shuffle_names,
               recipient = c(tail(shuffle_names, -1), shuffle_names[1])) %>% 
      left_join(names_email,by = c("sender" = "name"))

    walk2(gifts_assigned$email,gifts_assigned$recipient,~send_secret_santa_email(.x,.y,"yahoo_credential"))
    }

    assign_batch_emails(participants)
