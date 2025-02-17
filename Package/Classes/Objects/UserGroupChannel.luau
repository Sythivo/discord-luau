local Future = require("@Vendor/Future")

local Construct = require("@Utils/Construct")
local Extend = require("@Utils/Extend")

local ChannelBuilder = require("@Builders/ChannelBuilder")

local BaseUserChannel = require("@Objects/BaseUserChannel")

local DiscordEndpoints = require("@Data/DiscordEndpoints")

local CacheType = require("@Enums/CacheType")

--[=[
	@class Objects.UserGroupChannel

	Represents the implementation of a Discord Group Channel

	@tag inherit Objects.BaseUserChannel
]=]

--[=[
	@prop icon string
	@within Objects.UserGroupChannel
]=]

--[=[
	@prop ownerId string
	@within Objects.UserGroupChannel
]=]

--[=[
	@prop applicationId string
	@within Objects.UserGroupChannel
]=]

--[=[
	@prop managed boolean
	@within Objects.UserGroupChannel
]=]

local UserGroupChannel = {}

UserGroupChannel.Prototype = {}
UserGroupChannel.Interface = {}

UserGroupChannel.Prototype.type = "UserGroupChannel"

--[=[
	Modifies the thread channel settings asynchronously.
	
	@method modifyAsync
	@param channelBuilder ChannelBuilder.ChannelBuilder
	@within Objects.UserGroupChannel
	@return Vendor.Future<unknown>
]=]
function UserGroupChannel.Prototype.modifyAsync(self: UserGroupChannel, channelBuilder: ChannelBuilder.ChannelBuilder)
	return Future.try(function()
		return self.discordClient.discordGateway
			:patchAsync(string.format(DiscordEndpoints.BotModifyChannel, self.id), channelBuilder:toPayloadObject())
			:await()
	end)
end

function UserGroupChannel.Interface.new(
	discordClient,
	channelData: {
		id: string,
	}
)
	local self = discordClient.discordCache:getDataOr(CacheType.DiscordChannel, channelData.id, function()
		local channelStruct = {
			discordClient = discordClient,
		}

		return Construct(channelStruct, UserGroupChannel.Prototype)
	end)

	return (Extend(self, BaseUserChannel.new(discordClient, channelData)) :: unknown) :: UserGroupChannel
end

export type UserGroupChannel = BaseUserChannel.BaseUserChannel & typeof(UserGroupChannel.Prototype) & {
	discordClient: any,

	icon: string,
	ownerId: string,
	applicationId: string,

	managed: boolean,
}

return UserGroupChannel.Interface
