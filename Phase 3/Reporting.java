//Team 22: Hamayel Qureshi & Sean C. Barry
//Phase 3, Reporting.java

import java.sql.*;
import java.util.Scanner;

public class Reporting {

    static final String jdbcDriver = "oracle.jdbc.driver.OracleDriver";
    static final String dbURL = "jdbc:oracle:thin:@csorcl.cs.wpi.edu:1521:orcl";
    static String username = "";
    static String password = "";
    static String queryNo = "";
    static Connection connect;

    /**
     * tryLogin function to allow grader to login to database
     * @return boolean Returns whether or not login was successful
     */
    public static boolean tryLogin() {

        try {
            Class.forName(jdbcDriver);
        }
        catch(ClassNotFoundException exception) {
            exception.printStackTrace();
            return false;
        }
        System.out.println("Valid driver!");

        try {
            connect = DriverManager.getConnection(dbURL, username, password);
            System.out.println("Now attempting to connect to DB.");
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
        System.out.println("You have logged in successfully.");
        return true;
    }

    /**
     * passQuery function to try and pass queries into the Database. A helper function for the main arguments.
     * @param query Holding info for a patient's SSN/doctor's ID/etc.
     * @param queryID What query selection the user made
     */
    public static void passQuery(String query, String queryID) {
        try {
            String SQLQuery1 = null;
            String SQLQuery2 = null;
            String SQLQuery3 = null;

            Statement statement = connect.createStatement();

            if(queryID.equals("1"))
                SQLQuery1 = "SELECT * FROM Patient WHERE SSN = '"+query+"'";
            if(queryID.equals("2"))
                SQLQuery1 = "SELECT * FROM Doctor WHERE DoctorID = '"+query+"'";
            if(queryID.equals("3")) {
                SQLQuery1 = "SELECT * From Admission WHERE Admission_ID = '" + query + "'";
                SQLQuery2 = "SELECT DISTINCT Room_No, Start_Date, End_Date FROM Stays_In WHERE Admission_ID = '" + query + "'";
                SQLQuery3 = "SELECT DISTINCT DoctorID FROM Inspect WHERE Admission_ID '" + query + "'";
            }

            System.out.println("Running query: " +SQLQuery1+ "");
            ResultSet queryRes1 = statement.executeQuery(SQLQuery1);
            ResultSet queryRes2 = null;
            ResultSet queryRes3 = null;

            if(queryID.equals("3")) {
                System.out.println("Running query: " +SQLQuery2+ "");
                System.out.println("Running query: " +SQLQuery3+ "");
            }

            while(queryRes1.next()) {
                if(queryID.equals("1")) {
                    System.out.println("Patient SSN: " + queryRes1.getString("SSN"));
                    System.out.println("Patient First Name: " + queryRes1.getString("First_Name"));
                    System.out.println("Patient Last Name: " + queryRes1.getString("Last_Name"));
                    System.out.println("Patient Address: " + queryRes1.getString("Patient_Address"));
                }
                if(queryID.equals("2")) {
                    System.out.println("Doctor ID: " + queryRes1.getString("DoctorID"));
                    System.out.println("Doctor First Name: " + queryRes1.getString("First_Name"));
                    System.out.println("Doctor Last Name: " + queryRes1.getString("Last_Name"));
                    System.out.println("Doctor Gender: " + queryRes1.getString("Gender"));
                }
                if(queryID.equals("3")) {
                    System.out.println("Admission Number: " + queryRes1.getString("Admission_ID"));
                    System.out.println("Patient SSN: " + queryRes1.getString("Patient_SSN"));
                    System.out.println("Admission date (start date): " + queryRes1.getString("Admission_Time"));
                    System.out.println("Total Payment: " + queryRes1.getString("Total_Payment"));

                    System.out.println("Rooms: ");
                    queryRes2 = statement.executeQuery(SQLQuery2);
                    while(queryRes2.next()) {
                        System.out.println(" RoomNum: " + queryRes2.getString("Room_No")
                                + " FromDate: " + queryRes2.getString("Start_Date")
                                + " ToDate: " + queryRes2.getString("End_Date"));
                    }

                    System.out.println("Doctors examined the patient in this admission: ");
                    queryRes3 = statement.executeQuery(SQLQuery3);
                    while(queryRes3.next()) {
                        System.out.println("Doctor ID: " + queryRes3.getString("DoctorID"));
                    }
                }
            }

        }
        catch (SQLException exception) {
            exception.printStackTrace();
        }
    }

    /**
     * updateAdmissionPay is a helper function for the main argument where a user can update an admission payment!
     * @param admissionID The admission's unique identifier
     * @param updatedTotal The newly updated payment total
     */
    public static void updateAdmissionPay(String admissionID, String updatedTotal) {
        try {
            Statement statement = connect.createStatement();
            String SQLQuery = "UPDATE Admission SET Total_Payment = " + updatedTotal + "WHERE Admission_ID = " + admissionID + "";
            statement.executeQuery(SQLQuery);
            System.out.println("Payment info updated.");
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Main function to take care of user input
     * @param args Input from user
     */
    public static void main(String[] args) {

        if(args.length < 2 ) {
            Scanner userInput = new Scanner(System.in);
            System.out.print("Enter Username: ");
            username = userInput.next();
            System.out.print("Enter Password: ");
            password = userInput.next();
            System.out.print("Select Query Type: ");
            queryNo = userInput.next();
        }
        else {
            password = args[1];
            username = args[0];
        }

        if(!tryLogin()) {
            System.out.println("Username or Password Incorrect!\n");
        }

        if(args.length == 2) {
            System.out.println("Select your Database Function:\n");
            System.out.println("1- Report Patients Basic Information\n");
            System.out.println("2- Report Doctors Basic Information\n");
            System.out.println("3- Report Admissions Information\n");
            System.out.println("4- Update Admissions Payment\n");
        }

        if(args.length == 3) {
            Scanner userInput = new Scanner(System.in);
            queryNo = args[2];

            if(queryNo.equals("1")) {
                System.out.println("What is the patients SSN?: ");
                String SSN = userInput.next();
                passQuery(SSN, "1");
            }
            else if(queryNo.equals("2")) {
                System.out.println("What is the Doctor's ID?: ");
                String DoctorID = userInput.next();
                passQuery(DoctorID, "2");
            }
            else if(queryNo.equals("3")) {
                System.out.println("What is the Admission ID?: ");
                String AdmissionID = userInput.next();
                passQuery(AdmissionID, "3");
            }
            else if(queryNo.equals("4")) {
                System.out.println("What is the Admission ID for the payment update?: ");
                String AdmissionID = userInput.next();
                System.out.println("What is the new total?: ");
                String updatedTotal = userInput.next();
                updateAdmissionPay(AdmissionID, updatedTotal);
            }
            else {
                System.out.println("Invalid input! Please choose between options 1 and 4: \n");
                System.out.println("1- Report Patients Basic Information\n");
                System.out.println("2- Report Doctors Basic Information\n");
                System.out.println("3- Report Admissions Information\n");
                System.out.println("4- Update Admissions Payment\n");
            }
        }
        try {
            connect.close();
            System.out.println("Closing connection from server!");
        } catch (SQLException exception) {
            exception.printStackTrace();
        }
    }

}
