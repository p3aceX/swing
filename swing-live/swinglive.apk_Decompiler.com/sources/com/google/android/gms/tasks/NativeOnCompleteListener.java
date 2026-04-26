package com.google.android.gms.tasks;

/* JADX INFO: loaded from: classes.dex */
public class NativeOnCompleteListener implements OnCompleteListener<Object> {
    private final long zza;

    public NativeOnCompleteListener(long j4) {
        this.zza = j4;
    }

    public static void createAndAddCallback(Task<Object> task, long j4) {
        task.addOnCompleteListener(new NativeOnCompleteListener(j4));
    }

    public native void nativeOnComplete(long j4, Object obj, boolean z4, boolean z5, String str);

    @Override // com.google.android.gms.tasks.OnCompleteListener
    public void onComplete(Task<Object> task) {
        Object result;
        String message;
        Exception exception;
        if (task.isSuccessful()) {
            result = task.getResult();
            message = null;
        } else if (task.isCanceled() || (exception = task.getException()) == null) {
            result = null;
            message = null;
        } else {
            message = exception.getMessage();
            result = null;
        }
        nativeOnComplete(this.zza, result, task.isSuccessful(), task.isCanceled(), message);
    }
}
