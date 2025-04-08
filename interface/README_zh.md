# 爬虫 ZIP 包使用文档

[Englist Document](README.md)

## 简介

在 TSDAP 平台中，每一个爬虫都是一个独立的个体，以 ZIP 包的形式导入到平台中。每个爬虫包包含一个 `compose.json` 文件，用于描述爬虫的基本信息和配置。爬虫的主类需要继承 `ISpider` 接口，并实现其抽象方法。

## `compose.json` 文件结构

`compose.json` 文件包含以下几个部分：

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

### 字段说明

- `infos`: 包含爬虫的基本信息。
  - `name`: 爬虫名称。
  - `tag`: 爬虫版本。
  - `desc`: 爬虫描述。
  - `author`: 作者信息。

- `runtimes`: 包含爬虫运行时的配置信息。
  - `entry`: 爬虫的入口文件名。
  - `daemon`: 是否以守护进程方式运行。
  - `envs`: 运行时的环境变量。
  - `dependencies`: 爬虫依赖的 Python 包列表。

- `schedules`: 包含爬虫的调度信息。
  - `cron`: 使用 cron 表达式定义的调度时间。
    ```text
    *    *    *    *    *    *
    -    -    -    -    -    -
    |    |    |    |    |    |
    |    |    |    |    |    +----- 星期中星期几 (0 - 6) 周日=0
    |    |    |    |    +---------- 月份 (1 - 12)
    |    |    |    +--------------- 一个月中的第几天 (1 - 31)
    |    |    +-------------------- 小时 (0 - 23)
    |    +------------------------- 分钟 (0 - 59)
    +------------------------------ 秒 (0 - 59)
    ```

### 注意事项
- `daemon` 选项不能与 `cron` 选项同时使用。daemon 优先级大于 cron。
- `cron` 调度仅在爬虫正常退出的情况下才会调用。

## `ISpider` 接口

爬虫的主类需要继承 `ISpider` 接口，并实现其抽象方法。以下是 `ISpider` 接口的定义：

```python
class ISpider(ABC):
    """每个爬虫都有一个类需要继承并实现抽象函数，
    继承的类将作为爬虫的入口点。
    """

    def __init__(self) -> None:
        self.logger: logging.Logger
        """爬虫的日志记录器"""

    @abstractmethod
    def run(self) -> None:
        """爬虫的入口函数，必须重写"""
        pass

    @abstractmethod
    def unload(self) -> None:
      """爬虫的卸载函数，必须重写"""
      pass
```

### 接口说明
- `run`: 爬虫的入口函数, 如 main 函数一般, 该函数将作为平台启动爬虫的关键入口函数。
- `unload`: 爬虫的卸载函数, 当平台向爬虫发出 Stop 信号后, 将自动执行该函数, 可进行爬虫资源，进度的保存, 清理等工作。

---

### 方法说明
#### `alloc_thread`
向平台申请一个线程

函数原型
```python
def alloc_thread(self,
                 target_func: Callable,
                 thread_name: str | None = None,
                 args: Iterable[Any] = (),
                 kwargs: Mapping[str, Any] | None = None
                 ) -> Thread | None:
```

参数

| 名称 | 类型 | 默认值 | 描述 |
| --- | --- | --- | --- |
| `target_func` | Callable | 必填 | 线程要执行的目标函数 |
| `thread_name` | str \| None | None | 线程名称标识（可选） |
| `args` | Iterable[Any] | ( ) | 传递给目标函数的位置参数 |
| `kwargs` | Mapping[str, Any] \| None | None| 传递给目标函数的关键字参数 |

返回

成功返回 threading.Thread 实例，失败返回 None

---

#### `new_table`
在数据库中创建一个新表

函数原型
```python
def new_table(self,
              table_name: str,
              ref_data: Dict[str, Any]
              ) -> bool:
```

参数

| 名称 | 类型 | 默认值 | 描述 |
| --- | --- | --- | --- |
| `table_name` | str | 必填	| 要创建的表名称 |
| `ref_data` | Dict[str, Any] | 必填 | 列定义字典，表中的列名和列中的相应数据类型需要与一组完整的数据一起传递，以指示数据类型。<br />示例:  `{"id": 0, "name": ""}` |

返回

创建成功返回 True，失败返回 False

---

#### `read_last_data`

读取表中的最后一个数据，根据 `sorted_field` 字段进行排序。

函数原型
```python
def read_last_data(self,
                   table_name: str,
                   sorted_field: str,
                   sorted_n: int = 1,
                   sorted_method: Literal['ASC', 'DESC'] = 'DESC') -> List[Tuple]:
```

参数

| 名称 | 类型 | 默认值 | 描述 |
| --- | --- | --- | --- |
| `table_name` | str | 必填	| 目标表名称 |
| `sorted_field` | str | 必填 | 排序依据的字段名 |
| `sorted_n` | int | 1 | 取排序后 n 条数据 |
| `sorted_method` | Literal['ASC','DESC'] | 'DESC' | 排序方式：升序/降序 |

返回

包含最后 `sorted_n` 条数据的元组列表（例如：`[(1, "data1"), (2, "data2")]`）

---

#### `write_data`

写入单条数据到指定表

函数原型
```python
def write_data(self,
               table_name: str,
               data: Dict[str, Any]
               ) -> None:
```

参数

| 名称 | 类型 | 默认值 | 描述 |
| --- | --- | --- | --- |
| `table_name` | str | 必填	| 目标表名称 |
| `data` | Dict[str, Any] | 必填 | 要写入的数据字典<br>示例：`{"id": 1, "name": "test"}` |

返回

None

---

#### `read_stores`

读取一些需要持久存储但不是数据集的变量或数据

函数原型
```python
def read_stores(self,
                name: str
                ) -> Union[Any, None]:
```

参数

| 名称 | 类型 | 默认值 | 描述 |
| --- | --- | --- | --- |
| `name` | str | 必填	| 变量唯一标识 |

返回

成功则返回对应数据，失败返回 None

---

#### `write_stores`

写入一些需要持久存储但不是数据集的变量或数据

函数原型
```python
def write_stores(self,
                 name: str,
                 store_data: Any
                 ) -> bool:
```

参数

| 名称 | 类型 | 默认值 | 描述 |
| --- | --- | --- | --- |
| `name` | str | 必填	| 变量唯一标识 |
| `store_data` | Any | 必填 | 要存储的数据字典 |

返回

写入成功返回 True，失败返回 False

---

### 爬虫打包

爬虫需要通过 ZIP 格式进行打包。打包时，请确保以下文件和目录结构：

```text
your_spider.zip
├── compose.json
└── your_spider/
  ├── __init__.py
  └── main.py
```

- `compose.json`: 描述爬虫的基本信息和配置。
- `your_spider/`: 爬虫的代码目录。
  - `__init__.py`: 初始化文件。
  - `main.py`: 爬虫的主入口文件。

将上述结构打包成 ZIP 文件后，即可将其导入到 TSDAP 平台中进行运行。
若按照上述结构打包, 则`compose.json`中`entry`字段将填写为`your_spider/main`
