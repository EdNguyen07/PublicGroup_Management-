//==========================================================================
// ====================== INPUT TRUE(ADD) OR FALSE(REMOVE) =================

Boolean isAdd = TRUE; 

// =========================================================================
// ==================================== INPUTS USERS ID ====================

List<Id> userIds = new List<Id>{ 
    '005aj00000FuLZO', 
    '005aj00000FuLZP',
    '005aj00000FuLZX'
    
    };

// =========================================================================
// ==================================== INPUTS GROUP NAME ==================    
        
List<String> groupNames = new List<String>{ 
    'PP ESO TSC Great Lakes', 
    'PP ESO TSC Naples', 
    'PP ESO TSC NORFOLK', 
    'PP ESO TSC Pensacola',
    'PP ESO TSC San Diego',
    'PP ESO TSC Yokosuka', 
    'PP Legal TSC Great Lakes', 
    'PP Legal TSC Norfolk', 
    'PP Legal TSC Pensacola', 
    'PP Legal TSC San Diego', 
    'PP Legal TSC Yokosuka', 
    'PP Medical TSC Great Lakes', 
    'PP Medical TSC Naples', 
    'PP Medical TSC Norfolk', 
    'PP Medical TSC Pensacola', 
    'PP Medical TSC San Diego', 
    'PP Medical TSC Yokosuka'         
};
// ========================================================================= 

Map<Id, User> usersById = new Map<Id, User>([
    SELECT Id, Name, IsActive FROM User WHERE Id IN :userIds
]);

for (Id uid : userIds) {
    if (usersById.containsKey(uid)) {
        System.debug('👤 Found: ' + uid + ' => ' + usersById.get(uid).Name + ' => Active: '+usersById.get(uid).IsActive);
    } else {
        System.debug('❌ User ID not found: ' + uid);
    }
}

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
    System.debug('✅ Users added to public groups');
    
} else {
    // Remove users from groups 
    List<GroupMember> membersToDelete = [
        SELECT Id, UserOrGroupId
        FROM GroupMember
        WHERE GroupId IN :groupIds AND UserOrGroupId IN :userIds
    ];

    delete membersToDelete;
    System.debug('🗑️ Users removed from public groups');
}

