package O;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/* JADX INFO: loaded from: classes.dex */
public final class C implements LayoutInflater.Factory2 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final N f1206a;

    public C(N n4) {
        this.f1206a = n4;
    }

    @Override // android.view.LayoutInflater.Factory
    public final View onCreateView(String str, Context context, AttributeSet attributeSet) {
        return onCreateView(null, str, context, attributeSet);
    }

    @Override // android.view.LayoutInflater.Factory2
    public final View onCreateView(View view, String str, Context context, AttributeSet attributeSet) {
        boolean zIsAssignableFrom;
        U uG;
        boolean zEquals = B.class.getName().equals(str);
        N n4 = this.f1206a;
        if (zEquals) {
            return new B(context, attributeSet, n4);
        }
        if ("fragment".equals(str)) {
            String attributeValue = attributeSet.getAttributeValue(null, "class");
            TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, N.a.f1103a);
            if (attributeValue == null) {
                attributeValue = typedArrayObtainStyledAttributes.getString(0);
            }
            int resourceId = typedArrayObtainStyledAttributes.getResourceId(1, -1);
            String string = typedArrayObtainStyledAttributes.getString(2);
            typedArrayObtainStyledAttributes.recycle();
            if (attributeValue != null) {
                try {
                    zIsAssignableFrom = AbstractComponentCallbacksC0109u.class.isAssignableFrom(G.b(context.getClassLoader(), attributeValue));
                } catch (ClassNotFoundException unused) {
                    zIsAssignableFrom = false;
                }
                if (zIsAssignableFrom) {
                    int id = view != null ? view.getId() : 0;
                    if (id == -1 && resourceId == -1 && string == null) {
                        throw new IllegalArgumentException(attributeSet.getPositionDescription() + ": Must specify unique android:id, android:tag, or have a parent with an id for " + attributeValue);
                    }
                    AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109uB = resourceId != -1 ? n4.B(resourceId) : null;
                    if (abstractComponentCallbacksC0109uB == null && string != null) {
                        abstractComponentCallbacksC0109uB = n4.C(string);
                    }
                    if (abstractComponentCallbacksC0109uB == null && id != -1) {
                        abstractComponentCallbacksC0109uB = n4.B(id);
                    }
                    if (abstractComponentCallbacksC0109uB == null) {
                        G G4 = n4.G();
                        context.getClassLoader();
                        abstractComponentCallbacksC0109uB = G4.a(attributeValue);
                        abstractComponentCallbacksC0109uB.f1420t = true;
                        abstractComponentCallbacksC0109uB.f1388C = resourceId != 0 ? resourceId : id;
                        abstractComponentCallbacksC0109uB.f1389D = id;
                        abstractComponentCallbacksC0109uB.f1390E = string;
                        abstractComponentCallbacksC0109uB.f1421u = true;
                        abstractComponentCallbacksC0109uB.f1424y = n4;
                        C0113y c0113y = n4.v;
                        abstractComponentCallbacksC0109uB.f1425z = c0113y;
                        AbstractActivityC0114z abstractActivityC0114z = c0113y.f1433c;
                        abstractComponentCallbacksC0109uB.J = true;
                        if ((c0113y != null ? c0113y.f1432b : null) != null) {
                            abstractComponentCallbacksC0109uB.J = true;
                        }
                        uG = n4.a(abstractComponentCallbacksC0109uB);
                        if (N.J(2)) {
                            Log.v("FragmentManager", "Fragment " + abstractComponentCallbacksC0109uB + " has been inflated via the <fragment> tag: id=0x" + Integer.toHexString(resourceId));
                        }
                    } else {
                        if (abstractComponentCallbacksC0109uB.f1421u) {
                            throw new IllegalArgumentException(attributeSet.getPositionDescription() + ": Duplicate id 0x" + Integer.toHexString(resourceId) + ", tag " + string + ", or parent id 0x" + Integer.toHexString(id) + " with another fragment for " + attributeValue);
                        }
                        abstractComponentCallbacksC0109uB.f1421u = true;
                        abstractComponentCallbacksC0109uB.f1424y = n4;
                        C0113y c0113y2 = n4.v;
                        abstractComponentCallbacksC0109uB.f1425z = c0113y2;
                        AbstractActivityC0114z abstractActivityC0114z2 = c0113y2.f1433c;
                        abstractComponentCallbacksC0109uB.J = true;
                        if ((c0113y2 != null ? c0113y2.f1432b : null) != null) {
                            abstractComponentCallbacksC0109uB.J = true;
                        }
                        uG = n4.g(abstractComponentCallbacksC0109uB);
                        if (N.J(2)) {
                            Log.v("FragmentManager", "Retained Fragment " + abstractComponentCallbacksC0109uB + " has been re-attached via the <fragment> tag: id=0x" + Integer.toHexString(resourceId));
                        }
                    }
                    ViewGroup viewGroup = (ViewGroup) view;
                    P.c cVar = P.d.f1475a;
                    P.d.b(new P.a(abstractComponentCallbacksC0109uB, "Attempting to use <fragment> tag to add fragment " + abstractComponentCallbacksC0109uB + " to container " + viewGroup));
                    P.d.a(abstractComponentCallbacksC0109uB).getClass();
                    abstractComponentCallbacksC0109uB.f1395K = viewGroup;
                    uG.j();
                    uG.i();
                    throw new IllegalStateException(com.google.crypto.tink.shaded.protobuf.S.g("Fragment ", attributeValue, " did not create a view."));
                }
            }
        }
        return null;
    }
}
