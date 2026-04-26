package androidx.profileinstaller;

import O.RunnableC0093d;
import V.i;
import a0.InterfaceC0186b;
import android.content.Context;
import java.util.Collections;
import java.util.List;
import p1.d;

/* JADX INFO: loaded from: classes.dex */
public class ProfileInstallerInitializer implements InterfaceC0186b {
    @Override // a0.InterfaceC0186b
    public final List a() {
        return Collections.EMPTY_LIST;
    }

    @Override // a0.InterfaceC0186b
    public final Object b(Context context) {
        i.a(new RunnableC0093d(6, this, context.getApplicationContext()));
        return new d(23);
    }
}
