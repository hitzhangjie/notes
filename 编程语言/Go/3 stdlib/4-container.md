# 4 container

package container provides 3 common data structures, **list, ring, heap**.

**list**, is a doublely linked list implemention, it can be used as singlely/doublely linked list, stack and queue.
**ring**, is a circular doublely linked list, it can be used as list.
**heap**, is a minimum heap implemention, but if we change the meaning of ```Interface.Less(i,j int)``` to ```LargerThan(i,j int)```, then we can build a maximum heap.

## 4.1 list

**how to use it as stack?**

- func (l *List) PushBack(v interface{}) *Element
- func (l *List) Back() *Element

**how to use it as queue?**

- func (l *List) PushBack(v interface{}) *Element
- func (l *List) Front() *Element

**how to use it as list?**

- func (l *List) PushBack(v interface{}) *Element
- func (l *List) InsertBefore(v interface{}, mark *Element) *Element
- func (l *List) InsertAfter(v interface{}, mark *Element) *Element
- func (l *List) Remove(e *Element) interface{} 
- func (e *Element) Next() *Element
- func (e *Element) Prev() *Element

following is an example showing how to use package/list as stack, queue or doublely linked list.

```go
func testList() {
	lst := list.New()

	// used as stack
	fmt.Println("used as stack:")
	lst.PushBack(1)
	lst.PushBack(2)
	for lst.Len() > 0 {
		e := lst.Back()
		fmt.Println(e.Value)
		lst.Remove(e)
	}
	// used as queue
	fmt.Println("used as queue:")
	lst.Init()
	lst.PushBack(1)
	lst.PushBack(2)
	for lst.Len() > 0 {
		e := lst.Front()
		fmt.Println(e.Value)
		lst.Remove(e)
	}
	// used as double list
	fmt.Println("used as doublely linklist")
	lst.Init()
	lst.PushBack(1)
	lst.PushBack(3)
	lst.InsertAfter(2, lst.Front())
	for lst.Len() > 0 {
		e := lst.Front()
		fmt.Println(e.Value)
		lst.Remove(e)
	}
}
```

## 4.2 ring


## 4.3 heap

**how to use heap?**

- define a new type, for example, type StudentBook
- implement ```heap.Interface```, i.e, implement function Len(), Push(), Pop()
    - Len(), to calculate the length of underlying storage to control the range for building heap
    - Push(), to control how to push the element into underlying storage, and update its header
    - Pop, to get the already poped minimum element, and update the underlying storage header
- implement ```sort.Interface```, i.e, implement Less(i,j int), Swap(i,j int)
    - Less(i,j int), to determine how to reorder the elements in position i,j of underlying storage
    - Swap(i,j int), to determine how to swap the elements in position i,j of underlying storage

during the process of initializing or adjusting the heap, heap.Interface and sort.Interface will be called by the provided template function ```Down()``` and ```Up()```.

following is an example to build minimum or maximum heap.

```go
type Student struct {
	name  string
	age   int
	grade int
}

func (s Student) String() string {
	return fmt.Sprintf("name:%s, age:%d, grade:%d", s.name, s.age, s.grade)
}

type StudentBook []*Student

func (s *StudentBook) Len() int {
	return len(*s)
}

func (s *StudentBook) Less(i, j int) bool {
	return ((*s)[i].grade > (*s)[j].grade)         // build a maximum heap
	//return ((*s)[i].grade < (*s)[j].grade)         // build a minimum heap
}

func (s *StudentBook) Swap(i, j int) {
	(*s)[i], (*s)[j] = (*s)[j], (*s)[i]
}

func (s *StudentBook) Push(x interface{}) {
	*s = append(*s, x.(*Student))
}

func (s *StudentBook) Pop() interface{} {
	n := len(*s) - 1
	t := (*s)[n]
	*s = (*s)[0:n]
	return t
}

func testHeap() {
	s1 := &Student{"aaa", 20, 90}
	s2 := &Student{"bbb", 18, 100}
	s3 := &Student{"ccc", 21, 95}

	sb := &StudentBook{s1, s2, s3}
	heap.Init(sb)

	heap.Push(sb, &Student{"ddd", 20, 60})
	heap.Push(sb, &Student{"ddd", 20, 70})

	for sb.Len() > 0 {
		fmt.Println(heap.Pop(sb))
	}
}
```

## 4.4 summary

package container provides 3 common data structures, it could be very useful if we have some occations relevant to FILO, FIFO or selecting Maxium/Minimum element.

