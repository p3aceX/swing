package x0;

import com.google.android.gms.common.api.Scope;
import java.util.Comparator;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class d implements Comparator {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ d f6760b = new d(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6761a;

    public /* synthetic */ d(int i4) {
        this.f6761a = i4;
    }

    @Override // java.util.Comparator
    public final int compare(Object obj, Object obj2) {
        switch (this.f6761a) {
        }
        return ((Scope) obj).f3371b.compareTo(((Scope) obj2).f3371b);
    }
}
