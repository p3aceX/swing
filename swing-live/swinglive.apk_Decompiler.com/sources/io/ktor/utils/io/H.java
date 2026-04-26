package io.ktor.utils.io;

/* JADX INFO: loaded from: classes.dex */
public final class H extends IllegalStateException {
    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public H(String str, Throwable th) {
        super("Concurrent " + str + " attempts", th);
        J3.i.e(str, "taskName");
    }
}
