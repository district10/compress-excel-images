all: demo-out-1M.xlsx demo-out-500K.xlsx

demo-out-1M.xlsx: demo.xlsx
	source comprezer.sh; FILESIZE_THRESHOLD=10000000 comprezer $< $@

demo-out-500K.xlsx: demo.xlsx
	source comprezer.sh; FILESIZE_THRESHOLD=500000 comprezer $< $@
