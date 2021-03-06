Meteor.methods
	createDirectRoom: (toUsername) ->
		fromId = Meteor.userId()
		console.log '[methods] createDirectRoom -> '.green, 'fromId:', fromId, 'toUsername:', toUsername

		if Meteor.user().username is toUsername
			return

		roomId = [Meteor.user().username, toUsername].sort().join(',')

		userTo = Meteor.users.findOne { username: toUsername }

		me = Meteor.user()

		now = new Date()

		# create new room
		ChatRoom.upsert { _id: roomId },
			$set:
				usernames: [Meteor.user().username, toUsername]
			$setOnInsert:
				t: 'd'
				name: "#{me.name}|#{userTo.name}"
				msgs: 0
				ts: now

		ChatSubscription.upsert { $and: [{'u._id': Meteor.userId()}], rid: roomId },
			$set:
				ts: now
				ls: now
				name: userTo.name
			$setOnInsert:
				t: 'd'
				unread: 0
				'u._id': userTo._id

		ChatSubscription.upsert { $and: [{'u._id': userTo._id}], rid: roomId },
			$set:
				name: me.name
			$setOnInsert:
				t: 'd'
				unread: 0
				'u._id': userTo._id

		return {
			rid: roomId
		}
