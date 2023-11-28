zoom_o = Proto("zoom_o", "Zoom SFU Encapsulation")
zoom_o.fields.type = ProtoField.new("Type", "zoom_o.type", ftypes.UINT8)
zoom_o.fields.seq = ProtoField.new("Sequence number", "zoom_o.seq", ftypes.UINT16)
zoom_o.fields.ts = ProtoField.new("Timestamp (relative)", "zoom_o.ts", ftypes.UINT32)
zoom_o.fields.id = ProtoField.new("ID (Unknown)", "zoom_o.id", ftypes.UINT16)
zoom_o.fields.field = ProtoField.new("Field (Unknown)", "zoom_o.field", ftypes.UINT16)
zoom_o.fields.cont = ProtoField.new("Cont", "zoom_o.cont", ftypes.UINT8)
zoom_o.fields.hash_payload = ProtoField.new("Payload (hash)", "zoom_o.hash_payload", ftypes.BYTES)
zoom_o.fields.dir = ProtoField.new("Direction", "zoom_o.dir", ftypes.UINT8)

zoom = Proto("zoom", "Zoom Media Encapsulation")
zoom.fields.type = ProtoField.new("Type", "zoom.type", ftypes.UINT8)
zoom.fields.seq = ProtoField.new("Sequence number", "zoom.seq", ftypes.UINT16)
zoom.fields.ts = ProtoField.new("Timestamp", "zoom.ts", ftypes.UINT32)
zoom.fields.frame_num = ProtoField.new("Frame number", "zoom.frame_num", ftypes.UINT16)
zoom.fields.frame_pkt_count = ProtoField.new("Packets in frame", "zoom.frame_pkt_count", ftypes.UINT8)

zoom.fields.t13ts = ProtoField.new("T13 Timestamp", "zoom.t13ts", ftypes.UINT16)
zoom.fields.t13s = ProtoField.new("T13 Sequence number", "zoom.t13s", ftypes.UINT16)
zoom.fields.t13t = ProtoField.new("T13 Subtype", "zoom.t13t", ftypes.UINT8)

zoom_t32 = Proto("zoom_t32", "Zoom Type32")
zoom_t32.fields.sender = ProtoField.new("Video Sender", "zoom_t32.sender", ftypes.BYTES)
zoom_t32.fields.viewer = ProtoField.new("Video Viewer", "zoom_t32.viewer", ftypes.BYTES)
zoom_t32.fields.quality = ProtoField.new("Video Quality", "zoom_t32.quality", ftypes.UINT8)
zoom_t32.fields.seq1 = ProtoField.new("Sequence Number 1", "zoom_t32.seq1", ftypes.UINT16)
zoom_t32.fields.seq2 = ProtoField.new("Sequence Number 2", "zoom_t32.seq2", ftypes.UINT16)

zoom_t21 = Proto("zoom_t21", "Zoom Type21")
zoom_t21.fields.num = ProtoField.new("Number of Subfields", "zoom_t21.num", ftypes.UINT8)

zoom_t21_sub = Proto("zoom_t21_sub", "Zoom Type21 Subfield")
zoom_t21_sub.fields.id = ProtoField.new("Media Type", "zoom_t21_sub.id", ftypes.UINT8)
zoom_t21_sub.fields.uf1 = ProtoField.new("Unknown Field 1", "zoom_t21_sub.uf1", ftypes.UINT8)
zoom_t21_sub.fields.uf2 = ProtoField.new("Unknown Field 2", "zoom_t21_sub.uf2", ftypes.UINT8)
zoom_t21_sub.fields.uf3 = ProtoField.new("Timestamp", "zoom_t21_sub.timestamp", ftypes.UINT32)
zoom_t21_sub.fields.suffix_v = ProtoField.new("Length of Suffix - Video", "zoom_t21_sub.suffix_v", ftypes.UINT8)
zoom_t21_sub.fields.suffix_d = ProtoField.new("Length of Suffix - DS", "zoom_t21_sub.suffix_d", ftypes.UINT8)
zoom_t21_sub.fields.suffix_a = ProtoField.new("Length of Suffix - Audio", "zoom_t21_sub.suffix_a", ftypes.UINT8)

zoom_video = Proto("zoom_video", "Zoom Video RTP Extension")
zoom_video.fields.quality = ProtoField.new("Video Quality", "zoom_video.quality", ftypes.UINT8)
zoom_video.fields.seq1 = ProtoField.new("Sequence Number 1", "zoom_video.seq1", ftypes.UINT16)
zoom_video.fields.seq2 = ProtoField.new("Sequence Number 2", "zoom_video.seq2", ftypes.UINT16)

function get_type_desc(type)
    local desc = "Unknown"

    if type == 13 then
        desc = "Screen Share"
    elseif type == 15 then
        desc = "Audio"
    elseif type == 16 then
        desc = "Video"
    elseif type == 30 then
        desc = "Screen Share"
    elseif type == 32 then
        desc = "ZOOM_T32"
    elseif type == 33 or type == 34 or type == 35 then
        desc = "RTCP"
    end

    return desc
end

function get_zoom_o_dir_desc(dir)
    local desc = "Unknown"

    if dir == 0 then
        desc = "to Zoom"
    elseif dir == 4 then
        desc = "from Zoom"
    end

    return desc
end

function get_zoom_o_type_desc(type)
	local desc = "Unknown"
	if type == 1 then
		desc = "Handshake, To Zoom"
	elseif type == 2 then
		desc = "Handshake, From Zoom"
	elseif type == 3 then
		desc = "Req/Rep"
	elseif type == 4 then
		desc = "Req/Rep"
	elseif type == 7 then
		desc = "To Zoom"
	elseif type == 5 then 
		desc = "Multimedia"
	end

	return desc
end

-- Zoom Type32 (Receiver Report):
function zoom_t32.dissector(buf, pkt, tree)
    pkt.cols.protocol = zoom_t32.name

    local t = tree:add(zoom_t32, buf(), "Zoom Type32")
    t:add(zoom_t32.fields.sender, buf(0, 4))
    t:add(zoom_t32.fields.viewer, buf(4, 4))
    t:add(zoom_t32.fields.quality, buf(17, 1))
    t:add(zoom_t32.fields.seq1, buf(18, 2))
    t:add(zoom_t32.fields.seq2, buf(20, 2))
end

-- Zoom Video RTP Extension:
function zoom_video.dissector(buf, pkt, tree)
    pkt.cols.protocol = zoom_video.name

    local t = tree:add(zoom_video, buf(), "Zoom Video RTP Extension")
    t:add(zoom_video.fields.quality, bit.band(buf(0, 1):uint(), 3))
    t:add(zoom_video.fields.seq1, buf(1, 2))
    t:add(zoom_video.fields.seq2, buf(3, 2))
end

function zoom_t21.dissector(buf, pkt, tree)
    pkt.cols.protocol = zoom_t21.name
    len =   buf:len()
    if len > 800 then
        tree:add(zoom_t21, buf(), "Zoom Type21 Dummy")
        return end

    local typ = buf(4, 1):uint()

    if typ == 0x01 then
        tree:add(zoom_t21, buf(), "Zoom Type21: bw_level")
        return end
    
    if typ ~= 0xaa then
        tree:add(zoom_t21, buf(), "Zoom Type21: Unknown")
        return end
    
    local t = tree:add(zoom_t21, buf(), "Zoom Type21")

    local n = buf(3, 1):uint()
    local b = 4
    t:add(zoom_t21.fields.num, n)

    for i = 1, n, 1 do
        local suf = buf(b + 47, 1):uint()
        Dissector.get("zoom_t21_sub"):call(buf(b, 48 + suf):tvb(), pkt, tree)
        b = b + 48 + suf
    end

end

function t21_get_type(id)
    local desc = "unknown"
    if id == 1 then
        desc = "Audio"
    elseif id == 2 then
        desc = "DS"
    elseif id == 3 then
        desc = "Video"
    end
    return desc
end

function zoom_t21_sub.dissector(buf, pkt, tree)
    pkt.cols.protocol = zoom_t21_sub.name
    local t = tree:add(zoom_t21_sub, buf(), "Zoom Type21 Subfield")
    local i = buf(2, 1):uint()
    t:add(zoom_t21_sub.fields.id, buf(2, 1)):append_text(" (" .. t21_get_type(i) .. ")")
    t:add(zoom_t21_sub.fields.uf1, buf(23, 1))
    t:add(zoom_t21_sub.fields.uf2, buf(27, 1))
    t:add(zoom_t21_sub.fields.uf3, buf(28, 4))
    if i == 1 then
        t:add(zoom_t21_sub.fields.suffix_a, buf(47, 1))
    elseif i == 2 then
        t:add(zoom_t21_sub.fields.suffix_d, buf(47, 1))
    elseif i == 3 then
        t:add(zoom_t21_sub.fields.suffix_v, buf(47, 1))
    end
end

-- Zoom media encapsulation (inner header):
function zoom.dissector(buf, pkt, tree)
    len = buf:len()
    if len == 0 then return end
    pkt.cols.protocol = zoom.name

    local inner_type = buf(0, 1):uint()

    local t = tree:add(zoom, buf(), "Zoom Media Encapsulation")
    t:add(zoom.fields.type, buf(0, 1)):append_text(" (" .. get_type_desc(inner_type) .. ")")

    if inner_type == 1 then
        t:add(zoom.fields.seq, buf(9, 2))
        t:add(zoom.fields.ts, buf(11, 4))
        Dissector.get("rtp"):call(buf(26):tvb(), pkt, tree)
    elseif inner_type == 13 then
        t:add(zoom.fields.t13ts, buf(1, 2))
        t:add(zoom.fields.t13s, buf(3, 2))
        t:add(zoom.fields.t13t, buf(7, 1))

        if buf(7, 1):uint() == 0x1e then -- server screen sharing
            t:add(zoom.fields.seq, buf(16, 2))
            t:add(zoom.fields.ts, buf(18, 4))
            Dissector.get("rtp"):call(buf(27):tvb(), pkt, tree)
        end

    elseif inner_type == 15 then
        t:add(zoom.fields.seq, buf(9, 2))
        t:add(zoom.fields.ts, buf(11, 4))
        Dissector.get("rtp"):call(buf(19):tvb(), pkt, tree)
    elseif inner_type == 16 then
        t:add(zoom.fields.seq, buf(9, 2))
        t:add(zoom.fields.ts, buf(11, 4))

        if (buf(20, 1):uint() == 0x02) then
            t:add(zoom.fields.frame_num, buf(21, 2))
            t:add(zoom.fields.frame_pkt_count, buf(23, 1))

            if (bit.band(buf(25, 1):uint(), 0x7f) == 0x62) then
                Dissector.get("zoom_video"):call(buf(46, 5):tvb(), pkt, tree)
            end
            Dissector.get("rtp"):call(buf(24):tvb(), pkt, tree)

        else
            Dissector.get("rtp"):call(buf(20):tvb(), pkt, tree)
        end

    elseif inner_type == 21 then -- unclear what this type is
        -- t:add(zoom.fields.seq, buf(13, 2))
        Dissector.get("zoom_t21"):call(buf(8):tvb(), pkt, tree)
    elseif inner_type == 30 then -- P2P screen sharing
        t:add(zoom.fields.seq, buf(9, 2))
        t:add(zoom.fields.ts, buf(11, 4))
        Dissector.get("rtp"):call(buf(20):tvb(), pkt, tree)
    elseif inner_type == 32 then -- unclear what this type is
        Dissector.get("zoom_t32"):call(buf(2):tvb(), pkt, tree)
    elseif inner_type == 33 or inner_type == 34 or inner_type == 35 then
        Dissector.get("rtcp"):call(buf(16):tvb(), pkt, tree)
    else
        Dissector.get("data"):call(buf(15):tvb(), pkt, tree)
    end
end

-- Zoom server encapsulation (outer header):
function zoom_o.dissector(buf, pkt, tree)
    length = buf:len()
    if length == 0 then return end
    pkt.cols.protocol = zoom_o.name
	local outer_type = buf(0, 1):uint()

    local t = tree:add(zoom_o, buf(), "Zoom SFU Encapsulation")
    t:add(zoom_o.fields.type, buf(0, 1)):append_text(" (" .. get_zoom_o_type_desc(outer_type) .. ")")

	if outer_type == 1 then
		t:add(zoom_o.fields.id, buf(1, 2))
		t:add(zoom_o.fields.hash_payload, buf(3, 16))
	elseif outer_type == 2 then
		t:add(zoom_o.fields.id, buf(1, 2))
        t:add(zoom_o.fields.hash_payload, buf(3, 16))
	elseif outer_type == 3 then
		t:add(zoom_o.fields.seq, buf(3, 2))
		t:add(zoom_o.fields.ts, buf(5, 4))
		t:add(zoom_o.fields.id, buf(9, 2))
		t:add(zoom_o.fields.field, buf(11, 2))
		t:add(zoom_o.fields.cont, buf(13, 1))
		local cont = buf(13, 1):uint()
        if cont == 1 then
            Dissector.get("data"):call(buf(14):tvb(), pkt, tree)
        end
	elseif outer_type == 4 then
		t:add(zoom_o.fields.seq, buf(3, 2))
		t:add(zoom_o.fields.ts, buf(5, 4))
		t:add(zoom_o.fields.id, buf(9, 2))
		t:add(zoom_o.fields.field, buf(11, 2))
        t:add(zoom_o.fields.cont, buf(13, 1))
		local cont = buf(13, 1):uint()
		if cont == 1 then
        	Dissector.get("data"):call(buf(14):tvb(), pkt, tree)
		end
	elseif outer_type == 7 then
        t:add(zoom_o.fields.seq, buf(3, 2))
        t:add(zoom_o.fields.id, buf(5, 2))
        t:add(zoom_o.fields.field, buf(7, 2))
        t:add(zoom_o.fields.cont, buf(9, 1))
        local cont = buf(9, 1):uint()
        if cont == 1 then
            Dissector.get("data"):call(buf(10):tvb(), pkt, tree)
        end
    elseif outer_type == 5 then
		t:add(zoom_o.fields.seq, buf(1, 2))
        t:add(zoom_o.fields.id, buf(3, 2))
        t:add(zoom_o.fields.field, buf(5, 2))
	    t:add(zoom_o.fields.dir, buf(7, 1)):append_text(" (" .. get_zoom_o_dir_desc(buf(7, 1):uint()) .. ")")
        Dissector.get("zoom"):call(buf(8):tvb(), pkt, tree)
    else
        Dissector.get("data"):call(buf(9):tvb(), pkt, tree)
    end
end

-- per-default dissect all UDP port 8801 as Zoom Server Encap.
DissectorTable.get("udp.port"):add(8801, zoom_o)

-- allow selecting Zoom from "Decode as ..." context menu (for P2P traffic):
DissectorTable.get("udp.port"):add_for_decode_as(zoom)
