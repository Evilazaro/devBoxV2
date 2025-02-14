param roleAssignments array
param scope string = subscription().id
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleAssignment in roleAssignments: {
    name: guid(roleAssignment.principalId, roleAssignment.roleDefinitionId, roleAssignment.scope)
    properties: {
      principalId: roleAssignment.principalId
      roleDefinitionId: roleAssignment.roleDefinitionId
      scope: roleAssignment.scope
    }
  }
]
