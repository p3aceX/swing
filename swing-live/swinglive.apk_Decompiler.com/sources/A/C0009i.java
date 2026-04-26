package A;

import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

/* JADX INFO: renamed from: A.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0009i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public ViewParent f50a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ViewParent f51b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ViewGroup f52c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f53d;
    public int[] e;

    public C0009i(ViewGroup viewGroup) {
        this.f52c = viewGroup;
    }

    public final boolean a(float f4, float f5, boolean z4) {
        ViewParent viewParentE;
        if (this.f53d && (viewParentE = e(0)) != null) {
            try {
                return H.a(viewParentE, this.f52c, f4, f5, z4);
            } catch (AbstractMethodError e) {
                Log.e("ViewParentCompat", "ViewParent " + viewParentE + " does not implement interface method onNestedFling", e);
            }
        }
        return false;
    }

    public final boolean b(float f4, float f5) {
        ViewParent viewParentE;
        if (this.f53d && (viewParentE = e(0)) != null) {
            try {
                return H.b(viewParentE, this.f52c, f4, f5);
            } catch (AbstractMethodError e) {
                Log.e("ViewParentCompat", "ViewParent " + viewParentE + " does not implement interface method onNestedPreFling", e);
            }
        }
        return false;
    }

    public final boolean c(int i4, int i5, int[] iArr, int[] iArr2, int i6) {
        ViewParent viewParentE;
        int i7;
        int i8;
        if (!this.f53d || (viewParentE = e(i6)) == null) {
            return false;
        }
        if (i4 == 0 && i5 == 0) {
            if (iArr2 == null) {
                return false;
            }
            iArr2[0] = 0;
            iArr2[1] = 0;
            return false;
        }
        ViewGroup viewGroup = this.f52c;
        if (iArr2 != null) {
            viewGroup.getLocationInWindow(iArr2);
            i7 = iArr2[0];
            i8 = iArr2[1];
        } else {
            i7 = 0;
            i8 = 0;
        }
        if (iArr == null) {
            if (this.e == null) {
                this.e = new int[2];
            }
            iArr = this.e;
        }
        iArr[0] = 0;
        iArr[1] = 0;
        if (viewParentE instanceof InterfaceC0010j) {
            ((InterfaceC0010j) viewParentE).d(i4, i5, iArr, i6);
        } else if (i6 == 0) {
            try {
                H.c(viewParentE, viewGroup, i4, i5, iArr);
            } catch (AbstractMethodError e) {
                Log.e("ViewParentCompat", "ViewParent " + viewParentE + " does not implement interface method onNestedPreScroll", e);
            }
        }
        if (iArr2 != null) {
            viewGroup.getLocationInWindow(iArr2);
            iArr2[0] = iArr2[0] - i7;
            iArr2[1] = iArr2[1] - i8;
        }
        return (iArr[0] == 0 && iArr[1] == 0) ? false : true;
    }

    public final boolean d(int i4, int i5, int i6, int i7, int[] iArr, int i8, int[] iArr2) {
        ViewParent viewParentE;
        int i9;
        int i10;
        int[] iArr3;
        if (this.f53d && (viewParentE = e(i8)) != null) {
            if (i4 != 0 || i5 != 0 || i6 != 0 || i7 != 0) {
                ViewGroup viewGroup = this.f52c;
                if (iArr != null) {
                    viewGroup.getLocationInWindow(iArr);
                    i9 = iArr[0];
                    i10 = iArr[1];
                } else {
                    i9 = 0;
                    i10 = 0;
                }
                if (iArr2 == null) {
                    if (this.e == null) {
                        this.e = new int[2];
                    }
                    int[] iArr4 = this.e;
                    iArr4[0] = 0;
                    iArr4[1] = 0;
                    iArr3 = iArr4;
                } else {
                    iArr3 = iArr2;
                }
                if (viewParentE instanceof InterfaceC0011k) {
                    ((InterfaceC0011k) viewParentE).e(viewGroup, i4, i5, i6, i7, i8, iArr3);
                } else {
                    iArr3[0] = iArr3[0] + i6;
                    iArr3[1] = iArr3[1] + i7;
                    if (viewParentE instanceof InterfaceC0010j) {
                        ((InterfaceC0010j) viewParentE).b(viewGroup, i4, i5, i6, i7, i8);
                    } else if (i8 == 0) {
                        try {
                            H.d(viewParentE, viewGroup, i4, i5, i6, i7);
                        } catch (AbstractMethodError e) {
                            Log.e("ViewParentCompat", "ViewParent " + viewParentE + " does not implement interface method onNestedScroll", e);
                        }
                    }
                }
                if (iArr != null) {
                    viewGroup.getLocationInWindow(iArr);
                    iArr[0] = iArr[0] - i9;
                    iArr[1] = iArr[1] - i10;
                }
                return true;
            }
            if (iArr != null) {
                iArr[0] = 0;
                iArr[1] = 0;
                return false;
            }
        }
        return false;
    }

    public final ViewParent e(int i4) {
        if (i4 == 0) {
            return this.f50a;
        }
        if (i4 != 1) {
            return null;
        }
        return this.f51b;
    }

    public final boolean f(int i4) {
        return e(i4) != null;
    }

    public final boolean g(int i4, int i5) {
        boolean zF;
        if (!f(i5)) {
            if (this.f53d) {
                ViewGroup viewGroup = this.f52c;
                View view = viewGroup;
                for (ViewParent parent = viewGroup.getParent(); parent != null; parent = parent.getParent()) {
                    boolean z4 = parent instanceof InterfaceC0010j;
                    if (z4) {
                        zF = ((InterfaceC0010j) parent).f(view, viewGroup, i4, i5);
                    } else if (i5 == 0) {
                        try {
                            zF = H.f(parent, view, viewGroup, i4);
                        } catch (AbstractMethodError e) {
                            Log.e("ViewParentCompat", "ViewParent " + parent + " does not implement interface method onStartNestedScroll", e);
                            zF = false;
                        }
                    } else {
                        zF = false;
                    }
                    if (zF) {
                        if (i5 == 0) {
                            this.f50a = parent;
                        } else if (i5 == 1) {
                            this.f51b = parent;
                        }
                        if (z4) {
                            ((InterfaceC0010j) parent).a(view, viewGroup, i4, i5);
                        } else if (i5 == 0) {
                            try {
                                H.e(parent, view, viewGroup, i4);
                            } catch (AbstractMethodError e4) {
                                Log.e("ViewParentCompat", "ViewParent " + parent + " does not implement interface method onNestedScrollAccepted", e4);
                            }
                        }
                    } else {
                        if (parent instanceof View) {
                            view = (View) parent;
                        }
                    }
                }
            }
            return false;
        }
        return true;
    }

    public final void h(int i4) {
        ViewParent viewParentE = e(i4);
        if (viewParentE != null) {
            boolean z4 = viewParentE instanceof InterfaceC0010j;
            ViewGroup viewGroup = this.f52c;
            if (z4) {
                ((InterfaceC0010j) viewParentE).c(viewGroup, i4);
            } else if (i4 == 0) {
                try {
                    H.g(viewParentE, viewGroup);
                } catch (AbstractMethodError e) {
                    Log.e("ViewParentCompat", "ViewParent " + viewParentE + " does not implement interface method onStopNestedScroll", e);
                }
            }
            if (i4 == 0) {
                this.f50a = null;
            } else {
                if (i4 != 1) {
                    return;
                }
                this.f51b = null;
            }
        }
    }
}
