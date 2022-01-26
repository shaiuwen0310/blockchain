const WebHDFS = require("webhdfs");
const fs = require("fs");

/**
 * display a HDFS File
 */

let hdfs = WebHDFS.createClient({
    user: "hdfs",
    host: "192.168.101.249",
    port: 9870,
    path: "webhdfs/v1/"
});

const displayfile = async function(filename){
    
    // let hdfs_file_name = 'judy/wine1.json';
    let hdfs_file_name = filename;
    let remoteFileStream = hdfs.createReadStream( hdfs_file_name );

    remoteFileStream.on("error", function onError(err) { //handles error while read
        // Do something with the error
        console.log("...error: ", err);
    });
    let dataStream = [];
    remoteFileStream.on("data", function onChunk(chunk) { //on read success
        // Do something with the data chunk 
        dataStream.push(chunk);
        console.log('..chunk..',chunk);
    });
    remoteFileStream.on("finish", function onFinish() { //on read finish
        console.log('..on finish..');
        fs.writeFileSync('./tmp/write.json', dataStream.toString());
    });
};

exports.displayfile = displayfile;
