const Chat = require('../models/ChatModel');
const ObjectId = require('mongoose').Types.ObjectId;

class ChatRepository {

    async create({ lowerId, higherId }) {
        return await Chat.create({
            lowerId: ObjectId(lowerId),
            higherId: ObjectId(higherId),
            messages: [],
        });
    }

    async getChatByUsersIds({ lowerId, higherId }) {
        return await Chat.findOne({
            lowerId: ObjectId(lowerId),
            higherId: ObjectId(higherId)
        }).populate('lowerId').populate('higherId');
    }

    async getChatById(chatId) {
        return await Chat.findOne({ 
            _id: ObjectId(chatId)
        }).populate('lowerId').populate('higherId');
    }

    async getUserChats(userId) {
        return await Chat.find({
            $or: [
                { 'lowerId': ObjectId(userId) },
                { 'higherId': ObjectId(userId) }
            ]
        }).populate('lowerId').populate('higherId');
    }

    async updateChatMessages(chatId, messages) {
        return await Chat.findByIdAndUpdate(chatId, {
            $set: {
                messages
            }
        });
    }


}

module.exports = new ChatRepository();