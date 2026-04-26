package e1;

import java.security.GeneralSecurityException;
import javax.crypto.Mac;

/* JADX INFO: loaded from: classes.dex */
public final class m extends ThreadLocal {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ n f4001a;

    public m(n nVar) {
        this.f4001a = nVar;
    }

    @Override // java.lang.ThreadLocal
    public final Object initialValue() {
        n nVar = this.f4001a;
        try {
            j jVar = j.f3999c;
            Mac mac = (Mac) jVar.f4000a.e(nVar.f4003b);
            mac.init(nVar.f4004c);
            return mac;
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }
}
