package k3;

import D2.v;
import I.C0053n;
import O2.f;
import O2.k;
import android.content.Context;
import android.util.Log;
import java.io.File;
import java.util.ArrayList;
import y0.C0747k;

/* JADX INFO: renamed from: k3.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0516d implements K2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Context f5564a;

    public static void b(f fVar, final C0516d c0516d) {
        p1.d dVarM = fVar.m(new k());
        C0514b c0514b = C0514b.f5561d;
        C0053n c0053n = new C0053n(fVar, "dev.flutter.pigeon.path_provider_android.PathProviderApi.getTemporaryPath", c0514b, dVarM, 5);
        if (c0516d != null) {
            final int i4 = 0;
            c0053n.y(new O2.b(c0516d) { // from class: k3.a

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0516d f5560b;

                {
                    this.f5560b = c0516d;
                }

                @Override // O2.b
                public final void d(Object obj, v vVar) {
                    switch (i4) {
                        case 0:
                            C0516d c0516d2 = this.f5560b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, c0516d2.f5564a.getCacheDir().getPath());
                            } catch (Throwable th) {
                                arrayList = e1.k.I(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0516d c0516d3 = this.f5560b;
                            ArrayList arrayList2 = new ArrayList();
                            try {
                                Context context = c0516d3.f5564a;
                                File filesDir = context.getFilesDir();
                                if (filesDir == null) {
                                    filesDir = new File(context.getDataDir().getPath(), "files");
                                }
                                arrayList2.add(0, filesDir.getPath());
                            } catch (Throwable th2) {
                                arrayList2 = e1.k.I(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0516d c0516d4 = this.f5560b;
                            ArrayList arrayList3 = new ArrayList();
                            try {
                                Context context2 = c0516d4.f5564a;
                                File dir = context2.getDir("flutter", 0);
                                if (dir == null) {
                                    dir = new File(context2.getDataDir().getPath(), "app_flutter");
                                }
                                arrayList3.add(0, dir.getPath());
                            } catch (Throwable th3) {
                                arrayList3 = e1.k.I(th3);
                            }
                            vVar.f(arrayList3);
                            break;
                        case 3:
                            C0516d c0516d5 = this.f5560b;
                            ArrayList arrayList4 = new ArrayList();
                            try {
                                arrayList4.add(0, c0516d5.f5564a.getCacheDir().getPath());
                            } catch (Throwable th4) {
                                arrayList4 = e1.k.I(th4);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 4:
                            C0516d c0516d6 = this.f5560b;
                            ArrayList arrayList5 = new ArrayList();
                            try {
                                String absolutePath = null;
                                File externalFilesDir = c0516d6.f5564a.getExternalFilesDir(null);
                                if (externalFilesDir != null) {
                                    absolutePath = externalFilesDir.getAbsolutePath();
                                }
                                arrayList5.add(0, absolutePath);
                            } catch (Throwable th5) {
                                arrayList5 = e1.k.I(th5);
                            }
                            vVar.f(arrayList5);
                            break;
                        case 5:
                            C0516d c0516d7 = this.f5560b;
                            ArrayList arrayList6 = new ArrayList();
                            try {
                                c0516d7.getClass();
                                ArrayList arrayList7 = new ArrayList();
                                for (File file : c0516d7.f5564a.getExternalCacheDirs()) {
                                    if (file != null) {
                                        arrayList7.add(file.getAbsolutePath());
                                    }
                                }
                                arrayList6.add(0, arrayList7);
                            } catch (Throwable th6) {
                                arrayList6 = e1.k.I(th6);
                            }
                            vVar.f(arrayList6);
                            break;
                        default:
                            C0516d c0516d8 = this.f5560b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, c0516d8.a((EnumC0515c) ((ArrayList) obj).get(0)));
                            } catch (Throwable th7) {
                                arrayList8 = e1.k.I(th7);
                            }
                            vVar.f(arrayList8);
                            break;
                    }
                }
            });
        } else {
            c0053n.y(null);
        }
        C0053n c0053n2 = new C0053n(fVar, "dev.flutter.pigeon.path_provider_android.PathProviderApi.getApplicationSupportPath", c0514b, dVarM, 5);
        if (c0516d != null) {
            final int i5 = 1;
            c0053n2.y(new O2.b(c0516d) { // from class: k3.a

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0516d f5560b;

                {
                    this.f5560b = c0516d;
                }

                @Override // O2.b
                public final void d(Object obj, v vVar) {
                    switch (i5) {
                        case 0:
                            C0516d c0516d2 = this.f5560b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, c0516d2.f5564a.getCacheDir().getPath());
                            } catch (Throwable th) {
                                arrayList = e1.k.I(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0516d c0516d3 = this.f5560b;
                            ArrayList arrayList2 = new ArrayList();
                            try {
                                Context context = c0516d3.f5564a;
                                File filesDir = context.getFilesDir();
                                if (filesDir == null) {
                                    filesDir = new File(context.getDataDir().getPath(), "files");
                                }
                                arrayList2.add(0, filesDir.getPath());
                            } catch (Throwable th2) {
                                arrayList2 = e1.k.I(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0516d c0516d4 = this.f5560b;
                            ArrayList arrayList3 = new ArrayList();
                            try {
                                Context context2 = c0516d4.f5564a;
                                File dir = context2.getDir("flutter", 0);
                                if (dir == null) {
                                    dir = new File(context2.getDataDir().getPath(), "app_flutter");
                                }
                                arrayList3.add(0, dir.getPath());
                            } catch (Throwable th3) {
                                arrayList3 = e1.k.I(th3);
                            }
                            vVar.f(arrayList3);
                            break;
                        case 3:
                            C0516d c0516d5 = this.f5560b;
                            ArrayList arrayList4 = new ArrayList();
                            try {
                                arrayList4.add(0, c0516d5.f5564a.getCacheDir().getPath());
                            } catch (Throwable th4) {
                                arrayList4 = e1.k.I(th4);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 4:
                            C0516d c0516d6 = this.f5560b;
                            ArrayList arrayList5 = new ArrayList();
                            try {
                                String absolutePath = null;
                                File externalFilesDir = c0516d6.f5564a.getExternalFilesDir(null);
                                if (externalFilesDir != null) {
                                    absolutePath = externalFilesDir.getAbsolutePath();
                                }
                                arrayList5.add(0, absolutePath);
                            } catch (Throwable th5) {
                                arrayList5 = e1.k.I(th5);
                            }
                            vVar.f(arrayList5);
                            break;
                        case 5:
                            C0516d c0516d7 = this.f5560b;
                            ArrayList arrayList6 = new ArrayList();
                            try {
                                c0516d7.getClass();
                                ArrayList arrayList7 = new ArrayList();
                                for (File file : c0516d7.f5564a.getExternalCacheDirs()) {
                                    if (file != null) {
                                        arrayList7.add(file.getAbsolutePath());
                                    }
                                }
                                arrayList6.add(0, arrayList7);
                            } catch (Throwable th6) {
                                arrayList6 = e1.k.I(th6);
                            }
                            vVar.f(arrayList6);
                            break;
                        default:
                            C0516d c0516d8 = this.f5560b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, c0516d8.a((EnumC0515c) ((ArrayList) obj).get(0)));
                            } catch (Throwable th7) {
                                arrayList8 = e1.k.I(th7);
                            }
                            vVar.f(arrayList8);
                            break;
                    }
                }
            });
        } else {
            c0053n2.y(null);
        }
        C0053n c0053n3 = new C0053n(fVar, "dev.flutter.pigeon.path_provider_android.PathProviderApi.getApplicationDocumentsPath", c0514b, dVarM, 5);
        if (c0516d != null) {
            final int i6 = 2;
            c0053n3.y(new O2.b(c0516d) { // from class: k3.a

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0516d f5560b;

                {
                    this.f5560b = c0516d;
                }

                @Override // O2.b
                public final void d(Object obj, v vVar) {
                    switch (i6) {
                        case 0:
                            C0516d c0516d2 = this.f5560b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, c0516d2.f5564a.getCacheDir().getPath());
                            } catch (Throwable th) {
                                arrayList = e1.k.I(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0516d c0516d3 = this.f5560b;
                            ArrayList arrayList2 = new ArrayList();
                            try {
                                Context context = c0516d3.f5564a;
                                File filesDir = context.getFilesDir();
                                if (filesDir == null) {
                                    filesDir = new File(context.getDataDir().getPath(), "files");
                                }
                                arrayList2.add(0, filesDir.getPath());
                            } catch (Throwable th2) {
                                arrayList2 = e1.k.I(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0516d c0516d4 = this.f5560b;
                            ArrayList arrayList3 = new ArrayList();
                            try {
                                Context context2 = c0516d4.f5564a;
                                File dir = context2.getDir("flutter", 0);
                                if (dir == null) {
                                    dir = new File(context2.getDataDir().getPath(), "app_flutter");
                                }
                                arrayList3.add(0, dir.getPath());
                            } catch (Throwable th3) {
                                arrayList3 = e1.k.I(th3);
                            }
                            vVar.f(arrayList3);
                            break;
                        case 3:
                            C0516d c0516d5 = this.f5560b;
                            ArrayList arrayList4 = new ArrayList();
                            try {
                                arrayList4.add(0, c0516d5.f5564a.getCacheDir().getPath());
                            } catch (Throwable th4) {
                                arrayList4 = e1.k.I(th4);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 4:
                            C0516d c0516d6 = this.f5560b;
                            ArrayList arrayList5 = new ArrayList();
                            try {
                                String absolutePath = null;
                                File externalFilesDir = c0516d6.f5564a.getExternalFilesDir(null);
                                if (externalFilesDir != null) {
                                    absolutePath = externalFilesDir.getAbsolutePath();
                                }
                                arrayList5.add(0, absolutePath);
                            } catch (Throwable th5) {
                                arrayList5 = e1.k.I(th5);
                            }
                            vVar.f(arrayList5);
                            break;
                        case 5:
                            C0516d c0516d7 = this.f5560b;
                            ArrayList arrayList6 = new ArrayList();
                            try {
                                c0516d7.getClass();
                                ArrayList arrayList7 = new ArrayList();
                                for (File file : c0516d7.f5564a.getExternalCacheDirs()) {
                                    if (file != null) {
                                        arrayList7.add(file.getAbsolutePath());
                                    }
                                }
                                arrayList6.add(0, arrayList7);
                            } catch (Throwable th6) {
                                arrayList6 = e1.k.I(th6);
                            }
                            vVar.f(arrayList6);
                            break;
                        default:
                            C0516d c0516d8 = this.f5560b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, c0516d8.a((EnumC0515c) ((ArrayList) obj).get(0)));
                            } catch (Throwable th7) {
                                arrayList8 = e1.k.I(th7);
                            }
                            vVar.f(arrayList8);
                            break;
                    }
                }
            });
        } else {
            c0053n3.y(null);
        }
        C0053n c0053n4 = new C0053n(fVar, "dev.flutter.pigeon.path_provider_android.PathProviderApi.getApplicationCachePath", c0514b, dVarM, 5);
        if (c0516d != null) {
            final int i7 = 3;
            c0053n4.y(new O2.b(c0516d) { // from class: k3.a

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0516d f5560b;

                {
                    this.f5560b = c0516d;
                }

                @Override // O2.b
                public final void d(Object obj, v vVar) {
                    switch (i7) {
                        case 0:
                            C0516d c0516d2 = this.f5560b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, c0516d2.f5564a.getCacheDir().getPath());
                            } catch (Throwable th) {
                                arrayList = e1.k.I(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0516d c0516d3 = this.f5560b;
                            ArrayList arrayList2 = new ArrayList();
                            try {
                                Context context = c0516d3.f5564a;
                                File filesDir = context.getFilesDir();
                                if (filesDir == null) {
                                    filesDir = new File(context.getDataDir().getPath(), "files");
                                }
                                arrayList2.add(0, filesDir.getPath());
                            } catch (Throwable th2) {
                                arrayList2 = e1.k.I(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0516d c0516d4 = this.f5560b;
                            ArrayList arrayList3 = new ArrayList();
                            try {
                                Context context2 = c0516d4.f5564a;
                                File dir = context2.getDir("flutter", 0);
                                if (dir == null) {
                                    dir = new File(context2.getDataDir().getPath(), "app_flutter");
                                }
                                arrayList3.add(0, dir.getPath());
                            } catch (Throwable th3) {
                                arrayList3 = e1.k.I(th3);
                            }
                            vVar.f(arrayList3);
                            break;
                        case 3:
                            C0516d c0516d5 = this.f5560b;
                            ArrayList arrayList4 = new ArrayList();
                            try {
                                arrayList4.add(0, c0516d5.f5564a.getCacheDir().getPath());
                            } catch (Throwable th4) {
                                arrayList4 = e1.k.I(th4);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 4:
                            C0516d c0516d6 = this.f5560b;
                            ArrayList arrayList5 = new ArrayList();
                            try {
                                String absolutePath = null;
                                File externalFilesDir = c0516d6.f5564a.getExternalFilesDir(null);
                                if (externalFilesDir != null) {
                                    absolutePath = externalFilesDir.getAbsolutePath();
                                }
                                arrayList5.add(0, absolutePath);
                            } catch (Throwable th5) {
                                arrayList5 = e1.k.I(th5);
                            }
                            vVar.f(arrayList5);
                            break;
                        case 5:
                            C0516d c0516d7 = this.f5560b;
                            ArrayList arrayList6 = new ArrayList();
                            try {
                                c0516d7.getClass();
                                ArrayList arrayList7 = new ArrayList();
                                for (File file : c0516d7.f5564a.getExternalCacheDirs()) {
                                    if (file != null) {
                                        arrayList7.add(file.getAbsolutePath());
                                    }
                                }
                                arrayList6.add(0, arrayList7);
                            } catch (Throwable th6) {
                                arrayList6 = e1.k.I(th6);
                            }
                            vVar.f(arrayList6);
                            break;
                        default:
                            C0516d c0516d8 = this.f5560b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, c0516d8.a((EnumC0515c) ((ArrayList) obj).get(0)));
                            } catch (Throwable th7) {
                                arrayList8 = e1.k.I(th7);
                            }
                            vVar.f(arrayList8);
                            break;
                    }
                }
            });
        } else {
            c0053n4.y(null);
        }
        C0053n c0053n5 = new C0053n(fVar, "dev.flutter.pigeon.path_provider_android.PathProviderApi.getExternalStoragePath", c0514b, dVarM, 5);
        if (c0516d != null) {
            final int i8 = 4;
            c0053n5.y(new O2.b(c0516d) { // from class: k3.a

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0516d f5560b;

                {
                    this.f5560b = c0516d;
                }

                @Override // O2.b
                public final void d(Object obj, v vVar) {
                    switch (i8) {
                        case 0:
                            C0516d c0516d2 = this.f5560b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, c0516d2.f5564a.getCacheDir().getPath());
                            } catch (Throwable th) {
                                arrayList = e1.k.I(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0516d c0516d3 = this.f5560b;
                            ArrayList arrayList2 = new ArrayList();
                            try {
                                Context context = c0516d3.f5564a;
                                File filesDir = context.getFilesDir();
                                if (filesDir == null) {
                                    filesDir = new File(context.getDataDir().getPath(), "files");
                                }
                                arrayList2.add(0, filesDir.getPath());
                            } catch (Throwable th2) {
                                arrayList2 = e1.k.I(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0516d c0516d4 = this.f5560b;
                            ArrayList arrayList3 = new ArrayList();
                            try {
                                Context context2 = c0516d4.f5564a;
                                File dir = context2.getDir("flutter", 0);
                                if (dir == null) {
                                    dir = new File(context2.getDataDir().getPath(), "app_flutter");
                                }
                                arrayList3.add(0, dir.getPath());
                            } catch (Throwable th3) {
                                arrayList3 = e1.k.I(th3);
                            }
                            vVar.f(arrayList3);
                            break;
                        case 3:
                            C0516d c0516d5 = this.f5560b;
                            ArrayList arrayList4 = new ArrayList();
                            try {
                                arrayList4.add(0, c0516d5.f5564a.getCacheDir().getPath());
                            } catch (Throwable th4) {
                                arrayList4 = e1.k.I(th4);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 4:
                            C0516d c0516d6 = this.f5560b;
                            ArrayList arrayList5 = new ArrayList();
                            try {
                                String absolutePath = null;
                                File externalFilesDir = c0516d6.f5564a.getExternalFilesDir(null);
                                if (externalFilesDir != null) {
                                    absolutePath = externalFilesDir.getAbsolutePath();
                                }
                                arrayList5.add(0, absolutePath);
                            } catch (Throwable th5) {
                                arrayList5 = e1.k.I(th5);
                            }
                            vVar.f(arrayList5);
                            break;
                        case 5:
                            C0516d c0516d7 = this.f5560b;
                            ArrayList arrayList6 = new ArrayList();
                            try {
                                c0516d7.getClass();
                                ArrayList arrayList7 = new ArrayList();
                                for (File file : c0516d7.f5564a.getExternalCacheDirs()) {
                                    if (file != null) {
                                        arrayList7.add(file.getAbsolutePath());
                                    }
                                }
                                arrayList6.add(0, arrayList7);
                            } catch (Throwable th6) {
                                arrayList6 = e1.k.I(th6);
                            }
                            vVar.f(arrayList6);
                            break;
                        default:
                            C0516d c0516d8 = this.f5560b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, c0516d8.a((EnumC0515c) ((ArrayList) obj).get(0)));
                            } catch (Throwable th7) {
                                arrayList8 = e1.k.I(th7);
                            }
                            vVar.f(arrayList8);
                            break;
                    }
                }
            });
        } else {
            c0053n5.y(null);
        }
        C0053n c0053n6 = new C0053n(fVar, "dev.flutter.pigeon.path_provider_android.PathProviderApi.getExternalCachePaths", c0514b, dVarM, 5);
        if (c0516d != null) {
            final int i9 = 5;
            c0053n6.y(new O2.b(c0516d) { // from class: k3.a

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0516d f5560b;

                {
                    this.f5560b = c0516d;
                }

                @Override // O2.b
                public final void d(Object obj, v vVar) {
                    switch (i9) {
                        case 0:
                            C0516d c0516d2 = this.f5560b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, c0516d2.f5564a.getCacheDir().getPath());
                            } catch (Throwable th) {
                                arrayList = e1.k.I(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0516d c0516d3 = this.f5560b;
                            ArrayList arrayList2 = new ArrayList();
                            try {
                                Context context = c0516d3.f5564a;
                                File filesDir = context.getFilesDir();
                                if (filesDir == null) {
                                    filesDir = new File(context.getDataDir().getPath(), "files");
                                }
                                arrayList2.add(0, filesDir.getPath());
                            } catch (Throwable th2) {
                                arrayList2 = e1.k.I(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0516d c0516d4 = this.f5560b;
                            ArrayList arrayList3 = new ArrayList();
                            try {
                                Context context2 = c0516d4.f5564a;
                                File dir = context2.getDir("flutter", 0);
                                if (dir == null) {
                                    dir = new File(context2.getDataDir().getPath(), "app_flutter");
                                }
                                arrayList3.add(0, dir.getPath());
                            } catch (Throwable th3) {
                                arrayList3 = e1.k.I(th3);
                            }
                            vVar.f(arrayList3);
                            break;
                        case 3:
                            C0516d c0516d5 = this.f5560b;
                            ArrayList arrayList4 = new ArrayList();
                            try {
                                arrayList4.add(0, c0516d5.f5564a.getCacheDir().getPath());
                            } catch (Throwable th4) {
                                arrayList4 = e1.k.I(th4);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 4:
                            C0516d c0516d6 = this.f5560b;
                            ArrayList arrayList5 = new ArrayList();
                            try {
                                String absolutePath = null;
                                File externalFilesDir = c0516d6.f5564a.getExternalFilesDir(null);
                                if (externalFilesDir != null) {
                                    absolutePath = externalFilesDir.getAbsolutePath();
                                }
                                arrayList5.add(0, absolutePath);
                            } catch (Throwable th5) {
                                arrayList5 = e1.k.I(th5);
                            }
                            vVar.f(arrayList5);
                            break;
                        case 5:
                            C0516d c0516d7 = this.f5560b;
                            ArrayList arrayList6 = new ArrayList();
                            try {
                                c0516d7.getClass();
                                ArrayList arrayList7 = new ArrayList();
                                for (File file : c0516d7.f5564a.getExternalCacheDirs()) {
                                    if (file != null) {
                                        arrayList7.add(file.getAbsolutePath());
                                    }
                                }
                                arrayList6.add(0, arrayList7);
                            } catch (Throwable th6) {
                                arrayList6 = e1.k.I(th6);
                            }
                            vVar.f(arrayList6);
                            break;
                        default:
                            C0516d c0516d8 = this.f5560b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, c0516d8.a((EnumC0515c) ((ArrayList) obj).get(0)));
                            } catch (Throwable th7) {
                                arrayList8 = e1.k.I(th7);
                            }
                            vVar.f(arrayList8);
                            break;
                    }
                }
            });
        } else {
            c0053n6.y(null);
        }
        C0053n c0053n7 = new C0053n(fVar, "dev.flutter.pigeon.path_provider_android.PathProviderApi.getExternalStoragePaths", c0514b, dVarM, 5);
        if (c0516d == null) {
            c0053n7.y(null);
        } else {
            final int i10 = 6;
            c0053n7.y(new O2.b(c0516d) { // from class: k3.a

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0516d f5560b;

                {
                    this.f5560b = c0516d;
                }

                @Override // O2.b
                public final void d(Object obj, v vVar) {
                    switch (i10) {
                        case 0:
                            C0516d c0516d2 = this.f5560b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, c0516d2.f5564a.getCacheDir().getPath());
                            } catch (Throwable th) {
                                arrayList = e1.k.I(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0516d c0516d3 = this.f5560b;
                            ArrayList arrayList2 = new ArrayList();
                            try {
                                Context context = c0516d3.f5564a;
                                File filesDir = context.getFilesDir();
                                if (filesDir == null) {
                                    filesDir = new File(context.getDataDir().getPath(), "files");
                                }
                                arrayList2.add(0, filesDir.getPath());
                            } catch (Throwable th2) {
                                arrayList2 = e1.k.I(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0516d c0516d4 = this.f5560b;
                            ArrayList arrayList3 = new ArrayList();
                            try {
                                Context context2 = c0516d4.f5564a;
                                File dir = context2.getDir("flutter", 0);
                                if (dir == null) {
                                    dir = new File(context2.getDataDir().getPath(), "app_flutter");
                                }
                                arrayList3.add(0, dir.getPath());
                            } catch (Throwable th3) {
                                arrayList3 = e1.k.I(th3);
                            }
                            vVar.f(arrayList3);
                            break;
                        case 3:
                            C0516d c0516d5 = this.f5560b;
                            ArrayList arrayList4 = new ArrayList();
                            try {
                                arrayList4.add(0, c0516d5.f5564a.getCacheDir().getPath());
                            } catch (Throwable th4) {
                                arrayList4 = e1.k.I(th4);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 4:
                            C0516d c0516d6 = this.f5560b;
                            ArrayList arrayList5 = new ArrayList();
                            try {
                                String absolutePath = null;
                                File externalFilesDir = c0516d6.f5564a.getExternalFilesDir(null);
                                if (externalFilesDir != null) {
                                    absolutePath = externalFilesDir.getAbsolutePath();
                                }
                                arrayList5.add(0, absolutePath);
                            } catch (Throwable th5) {
                                arrayList5 = e1.k.I(th5);
                            }
                            vVar.f(arrayList5);
                            break;
                        case 5:
                            C0516d c0516d7 = this.f5560b;
                            ArrayList arrayList6 = new ArrayList();
                            try {
                                c0516d7.getClass();
                                ArrayList arrayList7 = new ArrayList();
                                for (File file : c0516d7.f5564a.getExternalCacheDirs()) {
                                    if (file != null) {
                                        arrayList7.add(file.getAbsolutePath());
                                    }
                                }
                                arrayList6.add(0, arrayList7);
                            } catch (Throwable th6) {
                                arrayList6 = e1.k.I(th6);
                            }
                            vVar.f(arrayList6);
                            break;
                        default:
                            C0516d c0516d8 = this.f5560b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, c0516d8.a((EnumC0515c) ((ArrayList) obj).get(0)));
                            } catch (Throwable th7) {
                                arrayList8 = e1.k.I(th7);
                            }
                            vVar.f(arrayList8);
                            break;
                    }
                }
            });
        }
    }

    public final ArrayList a(EnumC0515c enumC0515c) {
        String str;
        ArrayList arrayList = new ArrayList();
        Context context = this.f5564a;
        switch (enumC0515c.ordinal()) {
            case 0:
                str = null;
                break;
            case 1:
                str = "music";
                break;
            case 2:
                str = "podcasts";
                break;
            case 3:
                str = "ringtones";
                break;
            case 4:
                str = "alarms";
                break;
            case 5:
                str = "notifications";
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                str = "pictures";
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                str = "movies";
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                str = "downloads";
                break;
            case 9:
                str = "dcim";
                break;
            case 10:
                str = "documents";
                break;
            default:
                throw new RuntimeException("Unrecognized directory: " + enumC0515c);
        }
        for (File file : context.getExternalFilesDirs(str)) {
            if (file != null) {
                arrayList.add(file.getAbsolutePath());
            }
        }
        return arrayList;
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        try {
            b((f) c0747k.f6832c, this);
        } catch (Exception e) {
            Log.e("PathProviderPlugin", "Received exception while setting up PathProviderPlugin", e);
        }
        this.f5564a = (Context) c0747k.f6831b;
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        b((f) c0747k.f6832c, null);
    }
}
