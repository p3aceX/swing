package x;

import com.google.android.gms.common.internal.r;
import java.util.ArrayList;
import n.k;
import z.InterfaceC0769a;

/* JADX INFO: renamed from: x.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0707d implements InterfaceC0769a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6735a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f6736b;

    public /* synthetic */ C0707d(Object obj, int i4) {
        this.f6735a = i4;
        this.f6736b = obj;
    }

    @Override // z.InterfaceC0769a
    public final void accept(Object obj) {
        switch (this.f6735a) {
            case 0:
                C0708e c0708e = (C0708e) obj;
                if (c0708e == null) {
                    c0708e = new C0708e(-3);
                }
                ((r) this.f6736b).D(c0708e);
                return;
            default:
                C0708e c0708e2 = (C0708e) obj;
                synchronized (AbstractC0709f.f6741c) {
                    try {
                        k kVar = AbstractC0709f.f6742d;
                        ArrayList arrayList = (ArrayList) kVar.getOrDefault((String) this.f6736b, null);
                        if (arrayList == null) {
                            return;
                        }
                        kVar.remove((String) this.f6736b);
                        for (int i4 = 0; i4 < arrayList.size(); i4++) {
                            ((InterfaceC0769a) arrayList.get(i4)).accept(c0708e2);
                        }
                        return;
                    } finally {
                    }
                }
        }
    }
}
