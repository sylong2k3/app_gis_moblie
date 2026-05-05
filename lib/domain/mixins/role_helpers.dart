mixin RoleHelpers {
  String get role;

  bool get isOwner => role == 'OWNER';
  bool get isManager => role == 'MANAGER';
  bool get isMember => role == 'MEMBER';

  bool get canEdit => isOwner || isManager;
  bool get canDelete => isOwner;
  bool get canInviteMember => isOwner;
}
