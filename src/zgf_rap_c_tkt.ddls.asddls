@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ticket (projection)'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['TicketId']
define root view entity ZGF_RAP_C_TKT provider contract transactional_query as projection on ZGF_RAP_I_TKT
{
  key TicketId,
      Title,
      Description,
      Priority,
      Status,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
