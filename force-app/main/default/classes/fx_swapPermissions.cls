public with sharing class fx_swapPermissions {

            public static void swapPermission(String PermSetId1, String PermSetId2)
            {
                //Query Object Permissions for both PermissionSets

                List<ObjectPermissions> permObject1perms = new List<ObjectPermissions>([Select ParentId, PermissionsRead, PermissionsEdit, PermissionsCreate, 
                                                                                        PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords, SObjectType
                                                                                        FROM ObjectPermissions WHERE ParentId = :permSetId1]);

                List<ObjectPermissions> permObject2perms = new List<ObjectPermissions>([Select ParentId, PermissionsRead, PermissionsEdit, PermissionsCreate, 
                                                                                        PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords, SObjectType
                                                                                        FROM ObjectPermissions WHERE ParentId = :permSetId2]);

                //Query Field Level Permissions for both PermissionSets

                List<FieldPermissions> permSet1FieldPerms = [SELECT Id, ParentId, SObjectType,Field, PermissionsRead, PermissionsEdit
                                                            FROM FieldPermissions WHERE ParentId = :permSetId1
                                                            ];
                List<FieldPermissions> permSet2FieldPerms = [SELECT Id, ParentId, SObjectType,Field, PermissionsRead, PermissionsEdit
                                                            FROM FieldPermissions WHERE ParentId = :PermSetId2
                                                            ];

                // Query Tab Settings for both Permission Sets
                List<PermissionSetTabSetting> permSet1TabSettings = [SELECT Id, ParentId, Name, Visibility 
                                                                    FROM PermissionSetTabSetting WHERE ParentId = :PermSetId1
                                                                    ];
                List<PermissionSetTabSetting> permSet2TabSettings = [SELECT Id, ParentId, Name, Visibility 
                                                                    FROM PermissionSetTabSetting WHERE ParentId = :PermSetId2
                                                                    ];

                
                //Delete the existing Object Permissions and Field level permissions

                delete permObject1perms;
                delete permObject2perms;
                delete permSet1FieldPerms;
                delete permSet2FieldPerms;
                delete permSet1TabSettings;
                delete permSet2TabSettings;


                //Create new permissions for the Permission Set 1 and Permission Set2   

                List<ObjectPermissions> newObjectPermissions = new List<ObjectPermissions>();
                List<FieldPermissions>  newFieldPermissions = new List<FieldPermissions>();
                List<PermissionSetTabSetting> newTabSettings = new List<PermissionSetTabSetting>();

                //Assign PermissionSet1 Object level permissions to PermissionSet2
                for(ObjectPermissions perm :permObject1Perms)
                {
                    System.debug('Sobject Type is:'+perm.SObjectType);
                    newObjectPermissions.add(new Objectpermissions(
                                                                    Parentid=PermSetId2,SObjectType=perm.SObjectType,
                                                                    PermissionsRead = perm.PermissionsRead, PermissionsEdit = perm.PermissionsEdit,
                                                                    PermissionsCreate = perm.PermissionsCreate, PermissionsDelete = perm.PermissionsDelete,
                                                                    PermissionsViewAllRecords = perm.PermissionsViewAllRecords,
                                                                    PermissionsModifyAllRecords = perm.PermissionsModifyAllRecords
                                                                    )
                                            );
                }

                //Assign PermissionSet2 Object level permissions to PermissionSet1

                for(ObjectPermissions perm :permObject2Perms)
                {
                    newObjectPermissions.add(new Objectpermissions(
                                                                    Parentid=PermSetId1,SObjectType=perm.SObjectType,
                                                                    PermissionsRead = perm.PermissionsRead, PermissionsEdit = perm.PermissionsEdit,
                                                                    PermissionsCreate = perm.PermissionsCreate, PermissionsDelete = perm.PermissionsDelete,
                                                                    PermissionsViewAllRecords = perm.PermissionsViewAllRecords,
                                                                    PermissionsModifyAllRecords = perm.PermissionsModifyAllRecords
                                                                    )
                                            );
                }

                //Assign PermissionSet1 Field level permissions to PermissionSet2

                for(FieldPermissions perm :permSet1FieldPerms)
                {
                    System.debug('Sobject Type is:'+perm.SObjectType);
                    newFieldPermissions.add(new FieldPermissions(
                                                                        SobjectType = perm.SObjectType,ParentId = permSetId2, Field = perm.Field,
                                                                        PermissionsRead = perm.PermissionsRead, PermissionsEdit = perm.PermissionsEdit
                                                                    )
                                            );
                }

                //Assign PermissionSet2 Field level permissions to PermissionSet1

                for(FieldPermissions perm :permSet2FieldPerms)
                {
                    newFieldPermissions.add(new FieldPermissions(
                                                                        ParentId = permSetId1,SobjectType = perm.SObjectType, Field = perm.Field,
                                                                        PermissionsRead = perm.PermissionsRead, PermissionsEdit = perm.PermissionsEdit
                                                                    )
                                            );
                }

                // Assign PermissionSet1 Tab Settings to PermissionSet2
                for (PermissionSetTabSetting perm : permSet1TabSettings) 
                {
                    newTabSettings.add(new PermissionSetTabSetting(
                                                                        ParentId = PermSetId2, Name = perm.Name, Visibility = perm.Visibility
                                                                  )
                                      );
                }

                // Assign PermissionSet2 Tab Settings to PermissionSet1
                for (PermissionSetTabSetting perm : permSet2TabSettings) 
                {
                        newTabSettings.add(new PermissionSetTabSetting(
                                                                            ParentId = PermSetId1, Name = perm.Name, Visibility = perm.Visibility
                                                                    ) 
                                        );
                }


                //insert new permissions

                insert newObjectPermissions;
                insert newFieldPermissions;
                insert newTabSettings;

            }




}