global class ScheduledDiscount implements Schedulable {
    public static String sched = '0 00 00 * * ?';  //Every Day at Midnight 

    global static String scheduleMe() {
        ScheduledDiscount sd = new ScheduledDiscount(); 
        return System.schedule('Discount batch', sched, sd);
    }

    global void execute(SchedulableContext sc) {

        BatchCheckDiscount b1 = new BatchCheckDiscount();
        ID batchprocessid = Database.executeBatch(b1);
    }

}