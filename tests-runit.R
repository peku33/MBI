# Na podstawie http://www.johnmyleswhite.com/notebook/2010/08/17/unit-testing-in-r-the-bare-minimum/

library('RUnit')

test.suite <- defineTestSuite(
	"MBI",
	".",
)

test.result <- runTestSuite(test.suite)

printTextProtocol(test.result)