import requests
import json

# Replace with your personal access token
access_token = 'your_access_token_here'

# Replace with the number of the pull request you want to merge
pr_number = 123

# Replace with the name of the repository that contains the pull request
repo_name = 'owner/repo'

# Set the URL for the GitHub API endpoint for merging a pull request
url = f'https://api.github.com/repos/{repo_name}/pulls/{pr_number}/merge'

# Set the headers for the API request
headers = {
    'Authorization': f'token {access_token}',
    'Accept': 'application/vnd.github+json',
}

# Set the data for the API request
data = {
    'commit_message': 'Merge pull request #{}'.format(pr_number),
}

# Make the API request to merge the pull request
response = requests.patch(url, headers=headers, data=json.dumps(data))

# Check the status code of the API response
if response.status_code == 204:
    print('Pull request merged successfully!')
else:
    print('Error merging pull request:', response.json()['message'])
