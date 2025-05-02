// === INPUTS ===
List<Id> userIds = new List<Id>{ '005XXXXXXXXX001', '005XXXXXXXXX002' };
List<String> groupNames = new List<String>{ 'Sales Team', 'Marketing Access', 'Support Queue' };
Boolean isAdd = true; // Set to false to remove users

// === STEP 1: Get User Names for Logging ===
Map<Id, User> usersById = new Map<Id, User>([
    SELECT Id, Name FROM User WHERE Id IN :userIds
]);

// === STEP 2: Get Public Group IDs by Name ===
Map<String, Id> groupNameToId = new Map<String, Id>();
for (Group g : [
    SELECT Id, Name
    FROM Group
    WHERE Type = 'Regular' AND Name IN :groupNames
]) {
    groupNameToId.put(g.Name, g.Id);
}

Set<Id> groupIds = new Set<Id>(groupNameToId.values());

if (isAdd) {
    // === STEP 3A: Add users to groups ===
    List<GroupMember> membersToInsert = new List<GroupMember>();

    for (Id userId : userIds) {
        for (Id groupId : groupIds) {
            membersToInsert.add(new GroupMember(
                GroupId = groupId,
                UserOrGroupId = userId
            ));
        }
    }

    insert membersToInsert;
    System.debug('✅ Users added to public groups:');
    
} else {
    // === STEP 3B: Remove users from groups ===
    List<GroupMember> membersToDelete = [
        SELECT Id, UserOrGroupId
        FROM GroupMember
        WHERE GroupId IN :groupIds AND UserOrGroupId IN :userIds
    ];

    delete membersToDelete;
    System.debug('🗑️ Users removed from public groups:');
}

// === STEP 4: Print user details ===
for (Id uid : userIds) {
    if (usersById.containsKey(uid)) {
        System.debug(' - ' + uid + ' => ' + usersById.get(uid).Name);
    }
}
