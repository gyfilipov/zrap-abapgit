CLASS lhc_ticket DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CLASS-DATA last_ticket_id TYPE n LENGTH 8.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ticket RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ticket RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ticket.

    METHODS setStatusOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ticket~setStatusOpen.

    METHODS validateTitle FOR VALIDATE ON SAVE
      IMPORTING keys FOR ticket~validateTitle.

    METHODS validatePriority FOR VALIDATE ON SAVE
      IMPORTING keys FOR ticket~validatePriority.

    METHODS closeTicket FOR MODIFY
      IMPORTING keys FOR ACTION ticket~closeTicket RESULT result.
ENDCLASS.

CLASS lhc_ticket IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #( %create = if_abap_behv=>auth-allowed
                      %update = if_abap_behv=>auth-allowed
                      %delete = if_abap_behv=>auth-allowed
                      %action-closeTicket = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  " Closed tickets cannot be closed again.
  METHOD get_instance_features.
    READ ENTITIES OF zgf_rap_i_tkt IN LOCAL MODE
      ENTITY ticket FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(tickets).

    result = VALUE #( FOR ticket IN tickets
      ( %tky                = ticket-%tky
        %action-closeTicket = COND #( WHEN ticket-Status = 'C' THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  " Ticket number: a given number is kept, otherwise the next free one.
  METHOD earlynumbering_create.
    IF last_ticket_id IS INITIAL.
      SELECT MAX( ticket_id ) FROM zgf_rap_tkt INTO @last_ticket_id.
    ENDIF.

    LOOP AT entities INTO DATA(entity).
      IF entity-TicketId IS NOT INITIAL.
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO mapped-ticket.
        CONTINUE.
      ENDIF.
      last_ticket_id = last_ticket_id + 1.
      APPEND VALUE #( %cid = entity-%cid TicketId = last_ticket_id ) TO mapped-ticket.
    ENDLOOP.
  ENDMETHOD.

  " New tickets start with status O (open).
  METHOD setStatusOpen.
    READ ENTITIES OF zgf_rap_i_tkt IN LOCAL MODE
      ENTITY ticket FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(tickets).

    DELETE tickets WHERE Status IS NOT INITIAL.
    CHECK tickets IS NOT INITIAL.

    MODIFY ENTITIES OF zgf_rap_i_tkt IN LOCAL MODE
      ENTITY ticket UPDATE FIELDS ( Status )
      WITH VALUE #( FOR ticket IN tickets ( %tky = ticket-%tky Status = 'O' ) ).
  ENDMETHOD.

  " The title is mandatory.
  METHOD validateTitle.
    READ ENTITIES OF zgf_rap_i_tkt IN LOCAL MODE
      ENTITY ticket FIELDS ( Title ) WITH CORRESPONDING #( keys )
      RESULT DATA(tickets).

    LOOP AT tickets INTO DATA(ticket).
      IF ticket-Title IS INITIAL.
        APPEND VALUE #( %tky = ticket-%tky ) TO failed-ticket.
        APPEND VALUE #( %tky = ticket-%tky
                        %element-Title = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |The title is mandatory| ) )
          TO reported-ticket.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " Priority 1 (high) to 3 (low); empty is allowed.
  METHOD validatePriority.
    READ ENTITIES OF zgf_rap_i_tkt IN LOCAL MODE
      ENTITY ticket FIELDS ( Priority ) WITH CORRESPONDING #( keys )
      RESULT DATA(tickets).

    LOOP AT tickets INTO DATA(ticket).
      IF ticket-Priority IS NOT INITIAL AND ( ticket-Priority < 1 OR ticket-Priority > 3 ).
        APPEND VALUE #( %tky = ticket-%tky ) TO failed-ticket.
        APPEND VALUE #( %tky = ticket-%tky
                        %element-Priority = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |The priority must be 1, 2 or 3| ) )
          TO reported-ticket.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " Closing sets status C.
  METHOD closeTicket.
    MODIFY ENTITIES OF zgf_rap_i_tkt IN LOCAL MODE
      ENTITY ticket UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'C' ) ).

    READ ENTITIES OF zgf_rap_i_tkt IN LOCAL MODE
      ENTITY ticket ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(tickets).

    result = VALUE #( FOR ticket IN tickets ( %tky = ticket-%tky %param = ticket ) ).
  ENDMETHOD.

ENDCLASS.
