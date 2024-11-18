// File: sources/Registry.move
module PropertyRegistry::Registry {
    use std::string::String;
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Struct representing a property record
    struct Property has key, store {
        owner: address,
        property_id: String,
        registration_time: u64,
        is_verified: bool,
        property_value: u64,  // in APT tokens
    }

    /// Error codes
    const PROPERTY_ALREADY_REGISTERED: u64 = 1;
    const PROPERTY_NOT_FOUND: u64 = 2;
    const UNAUTHORIZED: u64 = 3;

    /// Function to register a new property
    public entry fun register_property(
        account: &signer,
        property_id: String,
        property_value: u64
    ) {
        let owner_address = signer::address_of(account);
        
        // Ensure property doesn't already exist
        assert!(!exists<Property>(owner_address), PROPERTY_ALREADY_REGISTERED);

        // Create new property record
        let property = Property {
            owner: owner_address,
            property_id,
            registration_time: timestamp::now_seconds(),
            is_verified: false,
            property_value,
        };

        // Store the property record
        move_to(account, property);
    }

    /// Function to transfer property ownership
    public entry fun transfer_property(
        current_owner: &signer,
        new_owner_address: address,
    ) acquires Property {
        let owner_address = signer::address_of(current_owner);
        
        // Ensure property exists and owned by sender
        assert!(exists<Property>(owner_address), PROPERTY_NOT_FOUND);
        
        // Move property to new owner
        let Property {
            owner: _,
            property_id,
            registration_time,
            is_verified,
            property_value,
        } = move_from<Property>(owner_address);

        // Create updated property record
        let updated_property = Property {
            owner: new_owner_address,
            property_id,
            registration_time,
            is_verified,
            property_value,
        };

        // Store updated record under new owner
        move_to(&signer::create_signer_for_testing(new_owner_address), updated_property);
    }
}
