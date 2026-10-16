@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ticket'
define root view entity ZGF_RAP_I_TKT as select from zgf_rap_tkt
{
      @EndUserText.label: 'Ticket'
  key ticket_id             as TicketId,
      @EndUserText.label: 'Title'
      title                 as Title,
      @EndUserText.label: 'Description'
      description           as Description,
      @EndUserText.label: 'Priority'
      priority              as Priority,
      @EndUserText.label: 'Status'
      status                as Status,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
