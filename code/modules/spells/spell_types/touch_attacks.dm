/obj/effect/proc_holder/spell/targeted/touch
	var/hand_path = /obj/item/melee/touch_attack
	var/obj/item/melee/touch_attack/attached_hand = null
	var/drawmessage = "You channel the power of the spell to my hand."
	var/dropmessage = "You draw the power out of my hand."
	invocation_type = "none" //you scream on connecting, not summoning
	include_user = TRUE
	range = -1

/obj/effect/proc_holder/spell/targeted/touch/Destroy()
	var/mob/user = usr
	if(attached_hand && ismob(attached_hand.loc))
		user = attached_hand.loc
	to_chat(user, span_notice("The power of the spell dissipates from my hand."))
	remove_hand()
	return ..()

/obj/effect/proc_holder/spell/targeted/touch/proc/remove_hand(recharge = FALSE)
	QDEL_NULL(attached_hand)
	if(recharge)
		charge_counter = charge_max

/obj/effect/proc_holder/spell/targeted/touch/proc/on_hand_destroy(obj/item/melee/touch_attack/hand)
	if(hand != attached_hand)
		CRASH("Incorrect touch spell hand.")
	//Start recharging.
	attached_hand = null
	recharging = TRUE
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/targeted/touch/cast(list/targets,mob/user = usr)
	if(!QDELETED(attached_hand))
		remove_hand(TRUE)
		to_chat(user, span_notice("[dropmessage]"))
		return

	for(var/mob/living/carbon/C in targets)
		if(!attached_hand)
			if(ChargeHand(C))
				recharging = FALSE
				return

/obj/effect/proc_holder/spell/targeted/touch/charge_check(mob/user,silent = FALSE)
	if(!QDELETED(attached_hand)) //Charge doesn't matter when putting the hand away.
		return TRUE
	else
		return ..()

/obj/effect/proc_holder/spell/targeted/touch/proc/ChargeHand(mob/living/carbon/user)
	attached_hand = new hand_path(src)
	attached_hand.attached_spell = src
	if(!user.put_in_hands(attached_hand))
		remove_hand(TRUE)
		if (user.get_num_arms() <= 0)
			to_chat(user, span_warning("I dont have any usable hands!"))
		else
			to_chat(user, span_warning("My hands are full!"))
		return FALSE
	to_chat(user, span_notice("[drawmessage]"))
	return TRUE

/obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone
	name = "Flesh to Stone"
	desc = ""
	hand_path = /obj/item/melee/touch_attack/fleshtostone

	school = "transmutation"
	charge_max = 600
	clothes_req = TRUE
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "statue"
	sound = 'sound/blank.ogg'
