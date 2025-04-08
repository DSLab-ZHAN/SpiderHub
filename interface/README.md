# Spider ZIP Package Usage Documentation

[中文文档](README_zh.md)

## Introduction

In the TSDAP platform, each spider operates as an independent entity imported in the form of a ZIP package. Each spider package contains a `compose.json` file that describes the spider's basic information and configurations. The main spider class must inherit the `ISpider` interface and implement its abstract methods.

## `compose.json` File Structure

The `compose.json` file contains the following sections:

```json
{
    "$schema": "./schema.json",
    "infos":{
        "name": "your_spider_name",
        "tag": "your_spider_tag",
        "description": "your spider description",
        "author": "author name"
    },
    "runtimes":{
        "entry": "entry_file",
        "daemon": false,
        "envs": {},
        "dependencies": []
    },
    "schedules":{
        "cron": "0 0 * * * *"
    }
}
```

### Field Descriptions

- `infos`: Contains basic spider information.
  - `name`: Spider name.
  - `tag`: Spider version tag.
  - `description`: Spider description.
  - `author`: Author information.

- `runtimes`: Contains runtime configurations.
  - `entry`: Entry filename for the spider.
  - `daemon`: Whether to run as a daemon process.
  - `envs`: Runtime environment variables.
  - `dependencies`: List of required Python dependencies.

- `schedules`: Contains scheduling configurations.
  - `cron`: Cron expression for scheduling.
    ```text
    * * * * * *
    - - - - - -
    | | | | | |
    | | | | | +----- Day of week (0-6, Sunday=0)
    | | | | +---------- Month (1-12)
    | | | +--------------- Day of month (1-31)
    | | +-------------------- Hour (0-23)
    | +------------------------- Minute (0-59)
    +------------------------------ Second (0-59)
    ```

### Notes
- The `daemon` option cannot be used simultaneously with `cron`. Daemon mode takes priority.
- `cron` scheduling only triggers when the spider exits normally.

## `ISpider` Interface

The main spider class must inherit the `ISpider` interface and implement its abstract methods. The interface definition is as follows:

```python
class ISpider(ABC):
    """Each spider must inherit this class and implement its abstract methods.
    The inherited class serves as the spider's entry point.
    """

    def __init__(self) -> None:
        self.logger: logging.Logger
        """Logger instance for the spider"""

    @abstractmethod
    def run(self) -> None:
        """Main entry function for the spider (must be overridden)"""
        pass

    @abstractmethod
    def unload(self) -> None:
        """Unload function for cleanup (must be overridden)"""
        pass
```

### Interface Description
- `run`: Main entry function serving as the startup point for the spider.
- `unload`: Cleanup function triggered when the platform sends a stop signal. Used for resource cleanup and progress saving.

---

### Method Specifications
#### `alloc_thread`
Requests a thread from the platform. Returns a Thread instance on success, otherwise None.

Function prototype:
```python
def alloc_thread(self,
                 target_func: Callable,
                 thread_name: str | None = None,
                 args: Iterable[Any] = (),
                 kwargs: Mapping[str, Any] | None = None
                 ) -> Thread | None:
```

Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `target_func` | Callable | Required | Target function for the thread |
| `thread_name` | str \| None | None | Thread identifier (optional) |
| `args` | Iterable[Any] | ( ) | Positional arguments for target function |
| `kwargs` | Mapping[str, Any] \| None | None| Keyword arguments for target function |

Returns

Returns a threading.Thread instance on success, None on failure.

---

#### `new_table`
Creates a new table in the database.

Function prototype:
```python
def new_table(self,
              table_name: str,
              ref_data: Dict[str, Any]
              ) -> bool:
```

Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `table_name` | str | Required | Name of the table to create |
| `ref_data` | Dict[str, Any] | Required | Column definitions dictionary. Pass a complete data sample indicating data types.<br />Example: `{"id": 0, "name": ""}` |

Returns

True on success, False on failure.

---

#### `read_last_data`
Reads the last data entry from a table, sorted by specified field.

Function prototype:
```python
def read_last_data(self,
                   table_name: str,
                   sorted_field: str,
                   sorted_n: int = 1,
                   sorted_method: Literal['ASC', 'DESC'] = 'DESC') -> List[Tuple]:
```

Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `table_name` | str | Required | Target table name |
| `sorted_field` | str | Required | Field name for sorting |
| `sorted_n` | int | 1 | Number of entries to retrieve |
| `sorted_method` | Literal['ASC','DESC'] | 'DESC' | Sorting method: ascending/descending |

Returns

A list of tuples containing the last `sorted_n` entries (e.g., `[(1, "data1"), (2, "data2")]`).

---

#### `write_data`
Writes a single data entry to a specified table.

Function prototype:
```python
def write_data(self,
               table_name: str,
               data: Dict[str, Any]
               ) -> None:
```

Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `table_name` | str | Required | Target table name |
| `data` | Dict[str, Any] | Required | Data dictionary to write<br>Example: `{"id": 1, "name": "test"}` |

Returns

None

---

#### `read_stores`
Reads persistent storage variables (non-dataset data).

Function prototype:
```python
def read_stores(self,
                name: str
                ) -> Dict[str, Any] | None:
```

Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | str | Required | Unique variable identifier |

Returns

Data dictionary on success, None on failure.

---

#### `write_stores`
Writes persistent storage variables (non-dataset data).

Function prototype:
```python
def write_stores(self,
                 name: str,
                 store_data: Dict[str, Any]
                 ) -> bool:
```

Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | str | Required | Unique variable identifier |
| `store_data` | Dict[str, Any] | Required | Data dictionary to store |

Returns

True on success, False on failure.

---

### Spider Packaging

Spiders must be packaged in ZIP format with the following directory structure:

```text
your_spider.zip
├── compose.json
└── your_spider/
  ├── __init__.py
  └── main.py
```

- `compose.json`: Describes spider configurations.
- `your_spider/`: Spider code directory.
- `__init__.py`: Initialization file.
- `main.py`: Main entry file.

After packaging with this structure, set the `entry` field in `compose.json` to `your_spider/main`. The ZIP package can then be imported into the TSDAP platform for execution.