# 03 - Slot-Based and Adaptive Layouts with `ModalCard` view

## Introduction

The `ModalCard` view component is meant to be a _reusable_ and _configurable_ modal by having it accept configurable parameters, both variables (state) and functions (behaviors); hence, an _adaptive_ layout that can be reused across apps.

Concepts being used in the `ModalCard` component build on top of the `Card` view component. Therefore, if you'd like to have a look at the `Card` view component before checking the `ModalCard`, head over to the <a href="https://github.com/saverio-negro/Card">Card View Component</a> Github project. It's quite a simple component, but you can take it as a groundwork for the `ModalCard` as well as more advanced components/frameworks I have coded.

## Component Description

As described above, the component is a reusable modal card with title, message, and customizable action slots.

While it's true that you can create your modal component depending on your purpose, my modal card is meant to better present confirmation dialogues or alerts with a customizable title and message, based on the specific scenario, as well as specific actions to perform upon confirmation or cancellation. However, this component shall serve you as a reference frame as far as how you will go about designing _your_ components based on the user experience needs.

With that out of the way, let's see how I implemented it.

First off, 

