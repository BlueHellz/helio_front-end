// FILE: org/settings/role_management.dart
// Org role list and permission editor.

class OrgSettingsRoleManagementContent {
  static const appBarTitle = 'Roles';
  static const fabAddRole = 'Add role';
  static const usersCountSuffix = ' users';
  static const assignUser = 'Assign user';
  static const editPermissions = 'Edit permissions';
  static const searchLabel = 'Search';
  static const dialogNewRole = 'New role';
  static const dialogEditRole = 'Edit role';
  static const labelName = 'Name';
  static const permissionsCaption = 'Permissions';
  static const permissionProjectsRead = 'projects.read';
  static const permissionProjectsWrite = 'projects.write';
  static const permissionCrmManage = 'crm.manage';
  static const permissionOrgSettings = 'org.settings';
  static const rolesLimitReached =
      'Your plan allows up to three roles. Upgrade or remove a role first.';
  static const assignSelected = 'Assign selected';
  static const noUsersSelected = 'Select at least one user';

  static const List<String> permissionOptions = [
    permissionProjectsRead,
    permissionProjectsWrite,
    permissionCrmManage,
    permissionOrgSettings,
  ];
}
