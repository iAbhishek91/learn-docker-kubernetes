# K8s API

There are three types of kinds

* Objects
* Lists
* Simple

## Objects

### Spec & Status

* If **Spec is deleted**, the object is purged from the system.
* If **Status is deleted**, then it can be recreated on fly, with some degradation of system behavior.
* POST and PUT **updates the Spec** of the object immediately.
* POST and PUT **updates the Status** of the object over time to align with the Spec.
* Multiple POST and PUT **updates the Status**, system will directly align its status to final state, instead of intermediate state. **level-based** rather than **edge-based**.
* POST and PUT **ignores the Status**. However, **Status must be provided** in order system to update the current state.
* Even for updating single field we need to **provide the entire Spec**. If a field in the spec is missing server assumes that client wants to delete that field.

### Structure of status

* **Conditions** represent the latest available observations of an object's state.
* There can be **multiple conditions** representing multiple status of the object. Hence conditions are represented as slice.
* Each condition MUST contain **status and type** as of today(15th July 2020)
  * Condition **status value** can be true, false or unknown.
* There are other common fields such as **Reason and Message**.
  * Reason are one word with camel case.
  * Message are one line human readable phrases.
* Adding **Fields in Conditions** should be discussed and then added. Only if its required.

### References to related objects

For example, we can **Pods are referred by RC**.

* In order to **keep GET request bounded in time and space**, the reference to the related object may be queried via different APIs. This means when we invoke GET on RC, API of RC will only give details about RC and not about the related Pod resources.

### Lists of named subobjects preferred over maps

* List of subobjects are defined as list and are NEVER map.
* exception to this rule is in pure objects like labels and annotations. *Pure objects are objects whose value never changes based for a specific input*

```yaml
ports:
  - name: www
    containerPort: 80

# below is not allowed
ports:
  www:
    containerPort: 80
```

### Primitive type used in the Object's API

* **Avoid floating value** as much as possible. Mostly never use it in Spec.
* **Avoid using unsigned integers** as its not compatible with other languages.
* Public numbers are always (u)int32 or (u)int64 and NOT (u)int. (u)int is ambiguous based on target system. However internal variables can be (u)int.
* **Avoid using enums**, use alias for string instead.
* **Bool are dangerous**, as many field starts with bool, then third possible values comes into picture.
* If number are either in magnitude or in **precision more that 53 bits**, should be serialized and accepted as String.

### Constants

* Certain fields have fixed values like *service type: ClusterIP, NodePort*. These are always starts with capital letter and camel cased.

## Lists and Simple

* they have a field called **metadata**.
* resourceVersion is valid only.
* A **resource version is only valid** within a single namespace on a single kind of resource
* When simple is sent to server or received from server they should be idempotent or Optimistic concurrency.
* Simple resource are often used to input alternate actions that modifies objects, hence resourceVersion of of simple resource should corresponds to resource version of the object.

## Docs: possible for PRs

Historical information status (e.g., last transition time, failure counts) is only provided with reasonable effort, and is not guaranteed to not be lost.

Confusion in types. avoid unsigned integer the they say about (u)int32 or (u)int64.
