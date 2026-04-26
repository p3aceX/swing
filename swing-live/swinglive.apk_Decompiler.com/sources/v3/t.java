package V3;

import a.AbstractC0184a;
import e1.AbstractC0367g;

/* JADX INFO: loaded from: classes.dex */
public abstract class t {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ int f2249a = 0;

    static {
        Object objH;
        Object objH2;
        Exception exc = new Exception();
        String simpleName = AbstractC0184a.class.getSimpleName();
        StackTraceElement stackTraceElement = exc.getStackTrace()[0];
        new StackTraceElement("_COROUTINE.".concat(simpleName), "_", stackTraceElement.getFileName(), stackTraceElement.getLineNumber());
        try {
            objH = A3.a.class.getCanonicalName();
        } catch (Throwable th) {
            objH = AbstractC0367g.h(th);
        }
        if (w3.e.a(objH) != null) {
            objH = "kotlin.coroutines.jvm.internal.BaseContinuationImpl";
        }
        try {
            objH2 = t.class.getCanonicalName();
        } catch (Throwable th2) {
            objH2 = AbstractC0367g.h(th2);
        }
        if (w3.e.a(objH2) != null) {
            objH2 = "kotlinx.coroutines.internal.StackTraceRecoveryKt";
        }
    }
}
