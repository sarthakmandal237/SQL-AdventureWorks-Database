# SQL-AdventureWorks-Database
In the SQL project I developed, the primary goal was to create a system that accurately tracks and calculates the total work hours of employees based on their check-in and check-out times. This project is essential for companies looking to streamline attendance management and ensure precise records of employee work hours.

The process begins with the creation of an EmployeeWorkLog table that records each employee's check-in and check-out times. Using SQL queries, the project identifies the first check-in and the last check-out for each employee on a given day, which are crucial for calculating total work hours. The FirstCheckIn and LastCheckOut common table expressions (CTEs) isolate these critical timestamps for each employee.

To handle scenarios where employees may check in and out multiple times in a day, the project includes a WorkSessions CTE, which pairs each check-in with the subsequent check-out. This ensures that the system accurately captures all work periods. The TotalOutCount CTE tracks the number of check-outs, providing an additional layer of verification to ensure all work sessions are accounted for.

Finally, the TotalWorkHours CTE calculates the total work minutes by summing the duration of each work session, converting these minutes into a standard hours and minutes format. The final SELECT statement compiles all the relevant data, including the first check-in, last check-out, total check-outs, and total work hours for each employee.

This SQL project not only meets the company's requirements for accurate work hour calculation but also provides a robust solution that can handle various attendance scenarios, ensuring reliable and efficient workforce management.
