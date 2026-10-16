CLASS zgf_rap_cl_eml_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zgf_rap_cl_eml_demo IMPLEMENTATION.

  " Create, change, close and delete a ticket with EML; every step prints what it finds.
  METHOD if_oo_adt_classrun~main.
    DATA failed   TYPE RESPONSE FOR FAILED   zgf_rap_i_tkt.
    DATA reported TYPE RESPONSE FOR REPORTED zgf_rap_i_tkt.

    " 1. create: the ticket number comes from early numbering, the status from the determination
    MODIFY ENTITIES OF zgf_rap_i_tkt
      ENTITY ticket
        CREATE FIELDS ( Title Priority )
        WITH VALUE #( ( %cid = 'T1' Title = 'EML demo' Priority = '2' ) )
      MAPPED DATA(mapped)
      FAILED failed
      REPORTED reported.
    COMMIT ENTITIES
      RESPONSE OF zgf_rap_i_tkt
      FAILED DATA(commit_failed)
      REPORTED DATA(commit_reported).
    IF commit_failed-ticket IS NOT INITIAL.
      out->write( |Create failed| ).
      RETURN.
    ENDIF.
    DATA(ticket_id) = mapped-ticket[ 1 ]-TicketId.
    out->write( |Created ticket { ticket_id }| ).

    READ ENTITIES OF zgf_rap_i_tkt
      ENTITY ticket ALL FIELDS WITH VALUE #( ( TicketId = ticket_id ) )
      RESULT DATA(tickets).
    out->write( |Status after create: { tickets[ 1 ]-Status }| ).

    " 2. update and action
    MODIFY ENTITIES OF zgf_rap_i_tkt
      ENTITY ticket
        UPDATE FIELDS ( Description )
        WITH VALUE #( ( TicketId = ticket_id Description = 'Changed by EML' ) )
        EXECUTE closeTicket FROM VALUE #( ( TicketId = ticket_id ) )
      FAILED failed
      REPORTED reported.
    COMMIT ENTITIES RESPONSE OF zgf_rap_i_tkt FAILED commit_failed REPORTED commit_reported.

    READ ENTITIES OF zgf_rap_i_tkt
      ENTITY ticket ALL FIELDS WITH VALUE #( ( TicketId = ticket_id ) )
      RESULT tickets.
    out->write( |Status after close: { tickets[ 1 ]-Status }| ).

    " 3. validation: an empty title is rejected when saving
    MODIFY ENTITIES OF zgf_rap_i_tkt
      ENTITY ticket
        CREATE FIELDS ( Title )
        WITH VALUE #( ( %cid = 'T2' Title = '' ) )
      FAILED failed
      REPORTED reported.
    COMMIT ENTITIES RESPONSE OF zgf_rap_i_tkt FAILED commit_failed REPORTED commit_reported.
    out->write( |Empty title rejected: { xsdbool( commit_failed-ticket IS NOT INITIAL ) }| ).

    " 4. delete
    MODIFY ENTITIES OF zgf_rap_i_tkt
      ENTITY ticket DELETE FROM VALUE #( ( TicketId = ticket_id ) )
      FAILED failed
      REPORTED reported.
    COMMIT ENTITIES RESPONSE OF zgf_rap_i_tkt FAILED commit_failed REPORTED commit_reported.
    out->write( |Deleted ticket { ticket_id }| ).
  ENDMETHOD.

ENDCLASS.
