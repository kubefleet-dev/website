import os
import subprocess
import time

from colorama import Fore, Back, Style

def print_char_by_char(text, delay=0.05):
    for ch in text:
        print(ch, end="", flush=True)
        time.sleep(delay)

def rainbow_print(text, delay=0.05):
    colors = [Fore.RED, Fore.YELLOW, Fore.LIGHTYELLOW_EX, Fore.GREEN, Fore.CYAN, Fore.BLUE, Fore.MAGENTA]
    color_idx = 0
    for ch in text:
        print(colors[color_idx] + ch, end="", flush=True)
        color_idx = (color_idx + 1) % len(colors)
        time.sleep(delay)
    print(Style.RESET_ALL, end="", flush=True)

s = Back.CYAN + "KubeFleet" + Style.RESET_ALL + " " + \
    "is a CNCF sandbox project that allows you " + \
    "to manage applications running on multiple Kubernetes seamlessly, on-premises and/or " + \
    "on the cloud."
print_char_by_char(s)
print_char_by_char("\n\n")
s = "A KubeFleet deployment features: \n" + \
    "* " + \
    Back.GREEN + "A hub cluster" + Style.RESET_ALL + \
    ", which serves as one unified portal for management; and\n" + \
    "* " + \
    Back.GREEN + "Up to hundreds of member clusters" + Style.RESET_ALL + \
    ", which run your workloads."
print_char_by_char(s)
print_char_by_char("\n\n")
s = Back.CYAN + "KubeFleet" + Style.RESET_ALL + " " + \
    "can greatly simplify many multi-cluster management tasks."
print_char_by_char(s)
print_char_by_char("\n")
s = "For example, you can use KubeFleet to " + \
    Fore.MAGENTA + "monitor your clusters easily " + Style.RESET_ALL + \
    "with one simple command:"
print_char_by_char(s)
print_char_by_char("\n\n")
print_char_by_char(Fore.YELLOW)
s = "kubectl get memberclusters"
print_char_by_char(s)
print_char_by_char("\n")
print_char_by_char(Style.RESET_ALL)

s = "Name       NodeCount   CPUCost   MemoryCost   CPU  CPULeft   Mem    MemLeft\n" + \
    "member-1   2           0.057     0.014        8    6         24Gi   12Gi"
# Add a delay for simulation purposes.
print_char_by_char(Fore.WHITE)
print_char_by_char(s, 0)
print_char_by_char(Style.RESET_ALL)
print_char_by_char("\n\n")

s = Back.CYAN + "KubeFleet" + Style.RESET_ALL + " " + \
    "features an API, " + \
    Back.CYAN + "ClusterResourcePlacement" + Style.RESET_ALL + \
    ", which you can use to " + \
    Fore.MAGENTA + "place resources easily across clusters. " + Style.RESET_ALL + \
    "The API looks like this:"
print_char_by_char(s)
print_char_by_char("\n")

s = """
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: work
spec:
  resourceSelectors:
    - group: ''
      kind: Namespace
      name: work
      version: v1
  policy:
    placementType: PickAll
"""

print_char_by_char(Fore.WHITE)
print_char_by_char(s, 0.02)
print_char_by_char(Style.RESET_ALL)
print_char_by_char("\n")

s = "When you create this object, the namespace " + \
    Back.YELLOW + "work" + Style.RESET_ALL + " " + \
    "and " + \
    Back.YELLOW + "all resources under the namespace" + Style.RESET_ALL + " " + \
    "will be placed to all clusters in the fleet. " + \
    "Use this API to run apps/services, execute jobs, bootstrap environments or enforce policies; " + \
    "even clusters joined afterwards can be automatically set up." 
print_char_by_char(s)
print_char_by_char("\n\n")

s = "And " + \
    Back.CYAN + "ClusterResourcePlacement" + Style.RESET_ALL + \
    " API can do so much more. "  + \
    Back.CYAN + "KubeFleet" + Style.RESET_ALL + \
    " features " + \
    Fore.MAGENTA + "advanced scheduling capabilities" + Style.RESET_ALL + \
    ", so you can select a subset of clusters using labels, or even pick the clusters " + \
    "with the cheapest CPU cost or the largest amount of available memory. " + \
    Back.CYAN + "KubeFleet" + Style.RESET_ALL + \
    " can also perform " + \
    Fore.MAGENTA + "advanced rollout based on resource readiness" + Style.RESET_ALL + \
    " or " + \
    Fore.MAGENTA + "override fields" + Style.RESET_ALL + \
    " automatically based on cluster specific configuration." 
print_char_by_char(s)
print_char_by_char("\n\n")

s = "Learn more about " + \
    Back.CYAN + "KubeFleet" + Style.RESET_ALL + " " + \
    "at "
print_char_by_char(s)
rainbow_print("https://kubefleet-dev.github.io/website/")
print_char_by_char(", or check out the source code at ")
rainbow_print("github.com/kubefleet-dev/kubefleet")
print_char_by_char(" ✨.\n")