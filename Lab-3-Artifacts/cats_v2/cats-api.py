from flask import Flask
import os, os.path, json
from shutil import copyfile

app = Flask(__name__)

@app.route('/cats/api/delete-pictures/<int:pic_by_number>', methods=['POST'])
def remove_picture(pic_by_number):
    file_to_remove = str(pic_by_number)+".jpg"
    try:
        os.remove(file_to_remove)
        return ("Successfully deleted image %s" % pic_by_number)
    except OSError:
        pass
    return ("No such image as %s.jpg" % pic_by_number)


@app.route('/cats/api/list-pictures/', methods=['GET'])
def which_pictures():

    remaining_files = {}
    for file_number in range(1,11):
        file_name = str(file_number) + ".jpg"
        if os.path.exists(file_name):
            remaining_files[file_name] = "true"
    response = app.response_class(response=json.dumps(remaining_files), status=200, mimetype='application/json')
    return response


@app.route('/cats/api/reset-pictures/', methods=['GET', 'POST'])
def reset_pictures():

    for file_number in range(1,11):
        source_file= "./backup-images/" + str(file_number) + ".jpg"
        dest_file= "./" + str(file_number) + ".jpg"
        copyfile(source_file, dest_file)

    return "Great Success!"


# run the app.
if __name__ == "__main__":
    app.run()
    

'''
Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
'''